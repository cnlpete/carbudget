/**
 * CarBudget, Sailfish application to manage car cost
 *
 * Copyright (C) 2014 Fabien Proriol
 *
 * This file is part of CarBudget.
 *
 * CarBudget is free software: you can redistribute it and/or modify it under the terms of the
 * GNU General Public License as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * CarBudget is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * See the GNU General Public License for more details. You should have received a copy of the GNU
 * General Public License along with CarBudget. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Fabien Proriol
 */


import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.carbudget 1.0


Dialog {
    property Tire tire
    property Tireset tireset
    property date buy_date
    property date trash_date

    SilicaFlickable {

        VerticalScrollDecorator {}

        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader { title: {
                    if(tire != undefined) return qsTr("Modify Tire")
                    else return qsTr("New Tire")
                }
            }

            ValueButton {
                function openDateDialog()
                {
                    var date = buy_date
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", { date: date })

                    dialog.accepted.connect(function()
                    {
                        value = dialog.date.toLocaleDateString(Qt.locale(),"d MMM yyyy")
                        buy_date = dialog.date
                    })
                }

                label: qsTr("Buy date")
                value: buy_date.toLocaleDateString(Qt.locale(),"d MMM yyyy")
                width: parent.width
                onClicked: openDateDialog()
            }

            ValueButton {
                function openDateDialog()
                {
                    var date = trash_date
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", { date: date })

                    dialog.accepted.connect(function()
                    {
                        value = dialog.date.toLocaleDateString(Qt.locale(),"d MMM yyyy")
                        trash_date = dialog.date
                    })
                }
                id:btnTrash
                label: "Trash date"
                visible: tire != undefined
                value: trash_date.toLocaleDateString(Qt.locale(),"d MMM yyyy")
                width: parent.width
                onClicked: openDateDialog()
            }

            TextField {
                id: nameinput
                anchors { left: parent.left; right: parent.right }
                focus: true
                label: qsTr("Name")
                placeholderText: qsTr("Name")

                EnterKey.enabled: text.length > 0 && acceptableInput == true
                EnterKey.onClicked: manufacturerinput.focus = true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
            }

            TextField {
                id: manufacturerinput
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Manufacturer")
                placeholderText: qsTr("Manufacturer")

                EnterKey.enabled: text.length > 0 && acceptableInput == true
                EnterKey.onClicked: modelinput.focus = true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
            }

            TextField {
                id: modelinput
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Model")
                placeholderText: qsTr("Model")

                EnterKey.enabled: text.length > 0 && acceptableInput == true
                EnterKey.onClicked: priceinput.focus = true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
            }


            TextField {
                id: priceinput
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Price")
                placeholderText: qsTr("Price")

                validator: RegExpValidator { regExp: /^[0-9\.,]{1,7}$/ }
                inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPrediction
                EnterKey.enabled: text.length > 0 && acceptableInput == true
                EnterKey.onClicked: quantityinput.focus = true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
            }

            ComboBox {
                id: quantityinput
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Quantity")
                menu: ContextMenu{
                    // show only numbers up to maximum tires in current tireset
                    id:quantityMenu
                    Repeater
                    {
                        model:quantityModel
                        MenuItem {
                            text: model.quantity
                        }
                    }
                }
            }

        }
    }
    canAccept: priceinput.acceptableInput && modelinput.acceptableInput && manufacturerinput.acceptableInput && nameinput.acceptableInput

    onOpened: {
        fillMenu()
        if(tire != undefined)
        {
            buy_date = tire.buydate
            trash_date = tire.trashdate
            btnTrash.enabled = false
            priceinput.text = tire.price
            //quantityinput.value = tire.quantity
            modelinput.text = tire.modelname
            manufacturerinput.text = tire.manufacturer
            nameinput.text = tire.name
            quantityinput.enabled = false //else we would change number of tires in a tireset which should not be allowed
        }
        else
        {
            console.log("Tire is undefined")
            buy_date = new Date()
            trash_date = new Date()
        }
    }

    onAccepted: {
        if(tire == undefined)
        {
            manager.car.addNewTire(buy_date,nameinput.text,manufacturerinput.text,modelinput.text,priceinput.text.replace(",","."), quantityinput.value,tireset.id )
        }
        else
        {
            tire.buydate = buy_date
            tire.trashdate = trash_date
            tire.name = nameinput.text
            tire.manufacturer = manufacturerinput.text
            tire.modelname = modelinput.text
            tire.price = priceinput.text.replace(",",".")
            //tire.quantity = quantity
            tire.save()
        }
    }
    ListModel {
        id:quantityModel
    }

    function fillMenu()
    {
        quantityModel.clear()
        for (var i=1;i <=manager.car.nbtire-tireset.tires_associated; i++)
        {
            console.log("Adding " + i.toString())
            quantityModel.append({quantity: i})
        }
    }
}
