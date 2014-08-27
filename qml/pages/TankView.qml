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


Page {
    allowedOrientations: Orientation.All
    SilicaListView {
        PullDownMenu {
            MenuItem {
                text: qsTr("Add full tank")
                onClicked: pageStack.push(Qt.resolvedUrl("TankEntry.qml"))
            }
        }

        VerticalScrollDecorator {}

        header: PageHeader {
            title: qsTr("Tank List")
        }


        anchors.fill: parent
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
        model: manager.car.tanks

        delegate: ListItem {
            width: parent.width - Theme.paddingMedium - Theme.paddingMedium
            showMenuOnPressAndHold: true

            onClicked: pageStack.push(Qt.resolvedUrl("TankEntryView.qml"), { tank: model.modelData })

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Modify")
                    onClicked: pageStack.push(Qt.resolvedUrl("TankEntry.qml"), { tank: model.modelData })
                }

                MenuItem {
                    text: qsTr("Remove")
                    onClicked: {
                        remorseAction(qsTr("Deleting"), function() {
                            manager.car.delTank(model.modelData)
                        })
                    }
                }
            }


            Column {
                width: parent.width

                Row {
                    width: parent.width

                    Text {
                        text: model.modelData.distance + ((model.modelData.consumption > 0)?(qsTr("km (+") + model.modelData.newDistance+qsTr("km)")):(qsTr("km")));

                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.primaryColor
                        width: parent.width / 2
                        horizontalAlignment: Text.AlignLeft
                    }

                    Text {
                        text: model.modelData.date.toLocaleDateString(Qt.locale(),"dd/MM/yyyy");

                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.primaryColor
                        width: parent.width / 2
                        horizontalAlignment: Text.AlignRight
                    }
                }
                Row {
                    width: parent.width

                    Text {
                        text: model.modelData.priceu.toFixed(3)+manager.car.currency+qsTr("/l");
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                        width: parent.width / 5
                    }
                    Text {
                        text: model.modelData.quantity +qsTr("l")
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                        width: parent.width / 5
                        horizontalAlignment: Text.AlignRight
                    }
                    Text {
                        text: model.modelData.price + manager.car.currency;
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                        width: parent.width / 5
                        horizontalAlignment: Text.AlignRight
                    }
                    Text {
                        text: model.modelData.consumption.toFixed(2)+ qsTr("l/100km");
                        visible: model.modelData.consumption > 0
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        width: 2 * parent.width / 5
                        color: {
                            if(model.modelData.consumption < manager.car.consumption * 0.92) return "#00FF00"
                            if(model.modelData.consumption < manager.car.consumption * 0.94) return "#40FF00"
                            if(model.modelData.consumption < manager.car.consumption * 0.96) return "#80FF00"
                            if(model.modelData.consumption < manager.car.consumption * 0.98) return "#C0FF00"
                            if(model.modelData.consumption < manager.car.consumption * 1.00) return "#FFFF00"
                            if(model.modelData.consumption < manager.car.consumption * 1.02) return "#FFC000"
                            if(model.modelData.consumption < manager.car.consumption * 1.04) return "#FF8000"
                            if(model.modelData.consumption < manager.car.consumption * 1.06) return "#FF4000"
                            if(model.modelData.consumption < manager.car.consumption * 1.08) return "#FF2000"
                            return "#FF0000"
                        }
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
