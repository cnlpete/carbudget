#ifndef IMPORTFUELIO_H
#define IMPORTFUELIO_H

#include "car.h"

class ImportFuelio
{
public:
    ImportFuelio(Car* car);

    void import(const QString& filename);

private:
    Car* _car;
    QString importDateFormat = "yyyy-MM-dd";

    QMap<int, int> costTypeMapping;

    static QString stripString(const QString& in);
    static QString get(const QList<QByteArray>& info, const QStringList& currentHeaderInfo, const QString& name);
    void importVehicleInfo(const QList<QByteArray> &info, const QStringList& currentHeaderInfo);
    void importFuelLog(const QList<QByteArray>& info, const QStringList& currentHeaderInfo);
    void importCostCategories(const QList<QByteArray>& info, const QStringList& currentHeaderInfo);
    void importCosts(const QList<QByteArray>& info, const QStringList& currentHeaderInfo);
};

#endif // IMPORTFUELIO_H
