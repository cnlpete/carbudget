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
    property string filter: ""
    allowedOrientations: Orientation.All
    property string distanceunit
    property real distanceunitfactor : 1.0

    Drawer {
        id: selectTankDateViewer
        anchors.fill: parent
        dock: Dock.Top
        open: false
        backgroundSize: tankview.contentHeight
    }
    SilicaFlickable {
        id: tankview
        interactive: !tanklistView.flicking
        pressDelay: 0
        anchors.fill: parent
        PageHeader {
            id: header
            title: qsTr("Tank Dates")
        }
        SilicaListView {

            VerticalScrollDecorator {}
            id:tanklistView
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingSmall
            anchors.rightMargin: Theme.paddingSmall
            clip: true
            onModelChanged: fillListModel()
            model: listModel
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
            VerticalScrollDecorator { flickable: tanklistView }
            delegate: ListItem {
                width: parent.width - Theme.paddingMedium - Theme.paddingMedium

                Column {
                    width: parent.width

                    Row {
                        width: parent.width

                        Text {
                            text: model.modelData.date.toLocaleDateString(Qt.locale(),"dd/MM/yyyy");
                            //text: "test"

                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.primaryColor
                            width: parent.width / 2
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }
    }
    ListModel {
        id:listModel
    }

    // Fill list model
    function fillListModel()
    {
        var tanklist = manager.car.tanks;
        for (var i = 0;i < tanklist.length ;i++)
        {
            //if ((filter=="")||(manager.car.getFueltypeName(tanklist[i].fueltype)==filter))
                listModel.append({"fuel" : tanklist[i]})
        }
    }
}
