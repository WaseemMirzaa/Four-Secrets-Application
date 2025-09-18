import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class BudgetItem extends StatefulWidget {
  final String taskName;
  final int initialAmount;
  final bool initialPaidStatus;
  final Function(String)? onChanged;
  final Function(BuildContext)? deleteFunction;
  final Function(bool)? onPaidStatusChanged;

  BudgetItem({
    super.key,
    required this.taskName,
    required this.initialAmount,
    required this.initialPaidStatus,
    required this.onChanged,
    required this.deleteFunction,
    required this.onPaidStatusChanged,
  });

  @override
  State<BudgetItem> createState() => _BudgetItemState();
}

class _BudgetItemState extends State<BudgetItem> {
  final double padValue = 15;
  late bool _switchOn;
  final FocusNode node1 = FocusNode();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _switchOn = widget.initialPaidStatus;
    _amountController.text = widget.initialAmount > 0
        ? widget.initialAmount.toString()
        : '';
  }

  dispose() {
    _amountController.dispose();
    node1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 25),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 3.5,
        child: Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: widget.deleteFunction,
                icon: FontAwesomeIcons.trashCan,
                backgroundColor: Colors.red.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [Colors.grey.shade200, Colors.grey.shade300],
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 275,
                      child: Text(
                        widget.taskName,
                        overflow: TextOverflow.clip,
                        softWrap: true,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 3.5)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 40,
                          width: 110,
                          child: GestureDetector(
                            onTap: () => _switchOn
                                ? null
                                : FocusScope.of(context).requestFocus(node1),
                            child: TextField(
                              focusNode: node1,
                              controller: _amountController,
                              onChanged: (value) {
                                if (widget.onChanged != null) {
                                  widget.onChanged!(value);
                                }
                              },
                              keyboardType: TextInputType.number,
                              readOnly: _switchOn,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                label: _switchOn == false
                                    ? Text(
                                        "Betrag",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      )
                                    : Text(
                                        "bezahlt",
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
                        Padding(padding: EdgeInsets.symmetric(horizontal: 25)),
                        FlutterSwitch(
                          height: 25,
                          width: 50,
                          activeColor: Color.fromARGB(255, 126, 80, 123),
                          inactiveColor: Colors.grey,
                          activeText: "bezahlt",
                          inactiveText: "offen",
                          borderRadius: 15,
                          value: _switchOn,
                          onToggle: (bool value) {
                            setState(() {
                              _switchOn = value;
                            });
                            if (widget.onPaidStatusChanged != null) {
                              widget.onPaidStatusChanged!(value);
                            }
                          },
                        ),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                        Text("bezahlt"),
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    child: Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      color: Colors.grey[600],
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
