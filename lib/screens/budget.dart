import 'package:flutter/services.dart';
import 'package:four_secrets_wedding_app/menue.dart';
import 'package:four_secrets_wedding_app/screens/budget_item.dart';
import 'package:four_secrets_wedding_app/screens/dialog_box.dart';
import 'package:four_secrets_wedding_app/model/four_secrets_divider.dart';
import 'package:flutter/material.dart';
import 'package:four_secrets_wedding_app/services/budget/budget_service.dart';
import 'package:four_secrets_wedding_app/utils/snackbar_helper.dart';

class Budget extends StatefulWidget {
  Budget({super.key});

  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  // text controller
  final _controller = TextEditingController();
  final _wholeBudgetController = TextEditingController();
  final FocusNode _wholeBudgetFocusNode = FocusNode();

  int wholeBudget = 0;
  int _tempBudget = 0;
  int _maxWholeBudget = 999999;
  bool _isOverBudget = false;
  int _overspentAmount = 0;
  bool _isLoading = true;
  int _totalCosts = 0;

  List budgetList = [];
  final BudgetService _firestoreService = BudgetService();
  Map<String, String> _budgetItemIds = {}; // To store Firestore document IDs

  @override
  void initState() {
    super.initState();
    _wholeBudgetController.addListener(_initializeBudget);
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final budgetData = await _firestoreService.loadBudgetData();
      setState(() {
        wholeBudget = budgetData['wholeBudget'];
        budgetList = budgetData['budgetItems'];
        _wholeBudgetController.text = wholeBudget.toString();

        // Initialize temporary values
        int tempCosts = calculateCosts();
        calculateBudget(tempCosts);
      });
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
        context,
        'Fehler beim Laden der Budgetdaten.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveBudgetData() async {
    try {
      // Convert budgetList to the format needed for Firestore
      List<Map<String, dynamic>> budgetItems = budgetList.map((item) {
        return {
          'name': item[0],
          'amount': item[1],
          'isPaid': item.length > 2 ? item[2] : false,
        };
      }).toList();

      await _firestoreService.saveBudgetData(
        wholeBudget: wholeBudget,
        budgetItems: budgetItems,
      );
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
        context,
        'Fehler beim Speichern des Budgets.',
      );
    }
  }

  void _initializeBudget() {
    if (int.tryParse(_wholeBudgetController.text) != null) {
      int newBudget = int.parse(_wholeBudgetController.text);
      if (newBudget >= 0 && newBudget <= _maxWholeBudget) {
        setState(() {
          wholeBudget = newBudget;
          int tempCosts = calculateCosts();
          calculateBudget(tempCosts);
        });
        _saveBudgetData();
      }
    } else {
      setState(() {
        wholeBudget = 0;
        int tempCosts = calculateCosts();
        calculateBudget(tempCosts);
      });
      _saveBudgetData();
    }
  }

  void _budgetChanged(String value, int index) {
    setState(() {
      if (int.tryParse(value) != null) {
        int costs = int.parse(value);
        if (costs >= 0 && costs <= _maxWholeBudget) {
          budgetList[index][1] = costs;
        }
      } else {
        budgetList[index][1] = 0;
      }
      int tempCosts = calculateCosts();
      calculateBudget(tempCosts);
    });
    _saveBudgetData();
  }

  int calculateCosts() {
    int costs = 0;
    for (var element in budgetList) {
      costs += element[1] as int;
    }
    setState(() {
      _totalCosts = costs;
    });
    calculateBudget(costs);
    return costs;
  }

  void calculateBudget(int costs) {
    final tempResult = wholeBudget - costs;
    _isOverBudget = tempResult < 0;
    _overspentAmount = _isOverBudget ? -tempResult : 0;
    _tempBudget = tempResult;
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
          isToDo: false,
          isGuest: false,
          isBudget: true,
        );
      },
    );
  }

  void saveNewTask() {
    if (_controller.text.isNotEmpty) {
      // Check if category already exists
      bool categoryExists = budgetList.any(
        (item) => item[0] == _controller.text,
      );

      if (categoryExists) {
        // Show error message if category already exists
        SnackBarHelper.showErrorSnackBar(
          context,
          'Diese Kategorie existiert bereits.',
        );
        Navigator.of(context).pop();
        return;
      }

      setState(() {
        budgetList.add([
          _controller.text,
          0,
          false,
        ]); // Add with default paid status as false
        _controller.clear();
      });
      Navigator.of(context).pop();
      _saveBudgetData(); // Save to Firestore after adding
    } else {
      // Show error message using the app-wide error snackbar
      SnackBarHelper.showErrorSnackBar(
        context,
        'Bitte geben Sie einen Namen für den Budgetposten ein.',
      );
    }
  }

  void onDelete(int index) async {
    // If the item has a document ID (fourth element in the array), delete it from Firestore
    if (budgetList[index].length > 3 && budgetList[index][3] != null) {
      try {
        await _firestoreService.deleteBudgetItem(budgetList[index][3]);
      } catch (e) {
        print('Delete error: $e');
        SnackBarHelper.showErrorSnackBar(
          context,
          'Fehler beim Löschen des Budgetpostens.',
        );
        return;
      }
    }

    setState(() {
      budgetList.removeAt(index);
      int tempCosts = calculateCosts();
      calculateBudget(tempCosts);
    });
    _saveBudgetData();
  }

  // Add this method to handle paid status changes
  void _updatePaidStatus(int index, bool isPaid) {
    setState(() {
      // Update the paid status in the budgetList
      if (budgetList[index].length < 3) {
        budgetList[index].add(isPaid);
      } else {
        budgetList[index][2] = isPaid;
      }
    });
    _saveBudgetData(); // Save to Firestore
  }

  @override
  void dispose() {
    _wholeBudgetFocusNode.dispose();
    _controller.dispose();
    _wholeBudgetController.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    // Unfocus everything in the current focus scope
    FocusScope.of(context).unfocus();
    // Also call the platform text input channel to ensure keyboard is hidden
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    // If you want, also unfocus specific node:
    _wholeBudgetFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Menue.getInstance(),
        appBar: AppBar(
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
          title: const Text('Budget'),
          backgroundColor: const Color.fromARGB(255, 107, 69, 106),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTask,
          child: const Icon(Icons.add),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : GestureDetector(
                onTap: () {
                  _hideKeyboard();
                  int tempCosts = calculateCosts();
                  calculateBudget(tempCosts);
                },
                child: ListView(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset(
                        'assets/images/budget/budget.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    FourSecretsDivider(),
                    Container(
                      padding: EdgeInsets.only(left: 25, right: 25, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Budget:",
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                          Container(
                            height: 40,
                            width: 120,
                            child: GestureDetector(
                              child: TextField(
                                autofocus: false,
                                controller: _wholeBudgetController,
                                focusNode: _wholeBudgetFocusNode,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  label: Text(
                                    "Betrag",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  isCollapsed: true,
                                  prefixIcon: Icon(
                                    Icons.euro_symbol_rounded,
                                    size: 18,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 126, 80, 123),
                                      width: 2,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    budgetList.isEmpty
                        ? Container(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.wallet,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Keine Budgetposten vorhanden",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Tippen Sie auf das + Symbol, um einen neuen Budgetposten hinzuzufügen. Geben Sie den Namen der Ausgabe (z. B. Friseur) und den Betrag ein.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: ClampingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 10),
                            itemCount: budgetList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return BudgetItem(
                                taskName: budgetList[index][0],
                                initialAmount: budgetList[index][1],
                                initialPaidStatus:
                                    budgetList[index][2] ?? false,
                                onChanged: (value) =>
                                    _budgetChanged(value, index),
                                deleteFunction: (context) => onDelete(index),
                                onPaidStatusChanged: (bool isPaid) {
                                  _updatePaidStatus(index, isPaid);
                                },
                              );
                            },
                          ),
                    FourSecretsDivider(),
                    Container(
                      padding: EdgeInsets.only(left: 25, right: 25, top: 10),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isOverBudget
                                ? Colors.red
                                : const Color.fromARGB(255, 107, 69, 106),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Guthaben:",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _isOverBudget
                                        ? "-${_overspentAmount.toString()} €"
                                        : "${_tempBudget.toString()} €",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Ausgaben:",
                                    style: TextStyle(
                                      color: _isOverBudget
                                          ? Colors.red
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${_totalCosts.toString()} €",
                                    style: TextStyle(
                                      color: _isOverBudget
                                          ? Colors.red
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isOverBudget)
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  "Warnung: Sie haben Ihr Budget um ${_overspentAmount} € überschritten!",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 45)),
                  ],
                ),
              ),
      ),
    );
  }
}
