#include "importfuelio.h"

ImportFuelio::ImportFuelio(Car *car) :
    _car(car),
    importDateFormat("yyyy-MM-dd")
{

}

QString ImportFuelio::stripString(const QString& in) {
    QString out = in.mid(1, in.length() - 2);
    return out;
}

QString ImportFuelio::get(const QList<QByteArray>& info, const QStringList& currentHeaderInfo, const QString& name) {
    const int index = currentHeaderInfo.indexOf(name);
    if (index != -1) {
        return stripString(QString(info[index]));
    }
    return "";
}

void ImportFuelio::importVehicleInfo(const QList<QByteArray>& info, const QStringList& currentHeaderInfo)
{
//    "Name",
//    "Description",
//    "DistUnit",
//    "FuelUnit",
//    "ConsumptionUnit",
//    "ImportCSVDateFormat",
//    "VIN",
//    "Insurance",
//    "Plate",
//    "Make",
//    "Model",
//    "Year",
//    "TankCount",
//    "Tank1Type",
//    "Tank2Type",
//    "Active",
//    "Tank1Capacity",
//    "Tank2Capacity",
//    "FuelUnitTank2",
//    "FuelConsumptionTank2"

    // Do not import the old car name
//    {
//        const int index = currentHeaderInfo.indexOf("Name");
//        if (index != -1) {
//            _car->setCar(info[index]);
//        }
//    }

    // 1: Description

    {
        static const QStringList distanceUnits = QStringList{"km", "mi"};
        int contentId = get(info, currentHeaderInfo, "DistUnit").toInt();
        _car->setDistanceUnit(distanceUnits[contentId]);
    }

    {
        static const QStringList consumptionUnits = QStringList{"l/100km", "mpg (us)", "mpg (uk)", "km/l", "km/gal (us)", "km/gal (uk)", "mi/l"}; // TODO
        int contentId = get(info, currentHeaderInfo, "ConsumptionUnit").toInt();
        _car->setConsumptionUnit(consumptionUnits[contentId]);
    }

        importDateFormat = get(info, currentHeaderInfo, "ImportCSVDateFormat");

    // 6 VIN
    // 7 Insurance

    _car->setLicensePlate(get(info, currentHeaderInfo, "Plate"));
    _car->setMake(get(info, currentHeaderInfo, "Make"));
    _car->setModel(get(info, currentHeaderInfo, "Model"));

    {
        int year = get(info, currentHeaderInfo, "Year").toInt();
        if (year > 0) {
            _car->setYear(year);
        }
    }

    {
        static const QStringList fuelTypes = QStringList{"", "Benzin", "Diesel", "Ethanol", "Autogas", "CNG", "Elektro", "Flex"}; // TODO
        // 100 = Benzin, 200 = Diesel, ...
        int contentId = get(info, currentHeaderInfo, "Tank1Type").toInt() / 100;
        _car->addNewFuelType(fuelTypes[contentId]);

        _car->setDefaultFuelType(_car->findFuelType(fuelTypes[contentId])->id());
    }

}

void ImportFuelio::importFuelLog(const QList<QByteArray>& info, const QStringList& currentHeaderInfo)
{
//    "Data",
//    "Odo (km)",
//    "Fuel (litres)",
//    "Full",
//    "Price (optional)",
//    "l/100km (optional)",
//    "latitude (optional)",
//    "longitude (optional)",
//    "City (optional)",
//    "Notes (optional)",
//    "Missed",
//    "TankNumber",
//    "FuelType",
//    "VolumePrice",
//    "StationID (optional)",
//    "ExcludeDistance",
//    "UniqueId",
//    "TankCalc"

    QDate date;
    unsigned int distance = 0;
    double quantity = 0.0;
    double price = 0.0;
    bool full = true;;
    bool missed = false;
    unsigned int fuelType = 0U;
    unsigned int station = 0U;
    QString note;

    date = QDate::fromString(get(info, currentHeaderInfo, "Data"), importDateFormat);
    distance = get(info, currentHeaderInfo, "Odo (km)").toDouble();
    quantity = get(info, currentHeaderInfo, "Fuel (litres)").toDouble();
    price = get(info, currentHeaderInfo, "Price (optional)").toDouble();
    full = get(info, currentHeaderInfo, "Full").toInt() == 1;
    missed = get(info, currentHeaderInfo, "Missed").toInt() == 1;
    note = get(info, currentHeaderInfo, "Notes (optional)");


    {
        static const QStringList fuelTypes = QStringList{"", "Benzin", "Diesel", "Ethanol", "Autogas", "CNG", "Elektro", "Flex"};
        // 100 = Benzin, 200 = Diesel, ...
        int contentId = get(info, currentHeaderInfo, "FuelType").toInt() / 100;
        _car->addNewFuelType(fuelTypes[contentId]);

        fuelType = _car->findFuelType(fuelTypes[contentId])->id();
    }
    // TODO stationid


    _car->addNewTank(date, distance, quantity, price, full, missed, fuelType, station, note);
}


void ImportFuelio::importCostCategories(const QList<QByteArray>& info, const QStringList& currentHeaderInfo)
{
//    "CostTypeID",
//    "Name",
//    "priority",
//    "color"

    const int importingId = get(info, currentHeaderInfo, "CostTypeID").toInt();
    const QString name = get(info, currentHeaderInfo, "Name");
    _car->addNewCostType(name);
    costTypeMapping.insert(importingId, _car->findCostType(name)->id());
}


void ImportFuelio::importCosts(const QList<QByteArray>& info, const QStringList& currentHeaderInfo)
{
//    "CostTitle",
//    "Date",
//    "Odo",
//    "CostTypeID",
//    "Notes",
//    "Cost",
//    "flag",
//    "idR",
//    "read",
//    "RemindOdo",
//    "RemindDate",
//    "isTemplate",
//    "RepeatOdo",
//    "RepeatMonths",
//    "isIncome",
//    "UniqueId"

    QDate date;
    unsigned int distance = 0;
    unsigned int costType = 0U;
    QString description;
    double price = 0.0;

    date = QDate::fromString(get(info, currentHeaderInfo, "Date"), importDateFormat);
    distance = get(info, currentHeaderInfo, "Odo").toDouble();
    costType = costTypeMapping[get(info, currentHeaderInfo, "CostTypeID").toInt()];
    description = get(info, currentHeaderInfo, "CostTitle");
    price = get(info, currentHeaderInfo, "Cost").toDouble();

    _car->addNewCost(date, distance, costType, description, price);
}

void ImportFuelio::import(const QString& filename)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << file.errorString();
        return;
    }

    QStringList wordList;
    enum class Mode {
        unknown,
        vehicleinfo,
        fuellog,
        costcategories,
        costs,
        stations,
        category
    };
    Mode currentMode = Mode::unknown;
    bool readHeaderLine = false;
    QStringList currentHeaderInfo;

    while (!file.atEnd()) {
        QByteArray line = file.readLine();

        if (line.startsWith("\"## ")) {
            if (line == "\"## Vehicle\"\n") {
                currentMode = Mode::vehicleinfo;
            } else if (line == "\"## Log\"\n") {
                currentMode = Mode::fuellog;
            } else if (line == "\"## CostCategories\"\n") {
                currentMode = Mode::costcategories;
            } else if (line == "\"## Costs\"\n") {
                currentMode = Mode::costs;
            } else if (line == "\"## FavStations\"\n") {
                currentMode = Mode::stations;
            } else if (line == "\"## Category\"\n") {
                currentMode = Mode::category;
            } else {
                qWarning() << "unknown heading" << line;
                currentMode = Mode::unknown;
            }
            readHeaderLine = false;
            currentHeaderInfo.clear();

            continue;
        }
        // read all the headings
        if (!readHeaderLine) {
            const QList<QByteArray> info = line.split(',');
            for (const QByteArray& entry: info) {
                currentHeaderInfo.append(stripString(entry));
            }
            readHeaderLine = true;
            continue;
        }

        const QList<QByteArray> info = line.split(',');
        switch (currentMode) {
            case Mode::vehicleinfo: {
                importVehicleInfo(info, currentHeaderInfo);
                break;
            }
            case Mode::fuellog: {
                importFuelLog(info, currentHeaderInfo);
                break;
            }
            case Mode::costcategories: {
                importCostCategories(info, currentHeaderInfo);
                break;
            }
            case Mode::costs: {
                importCosts(info, currentHeaderInfo);
                break;
            }

            // TODO stations
            // TODO category
        }
    }


}
