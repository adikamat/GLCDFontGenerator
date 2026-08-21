#ifndef GLYPHDATA_H
#define GLYPHDATA_H

#include <QAbstractListModel>
#include <QString>
#include <QJsonObject>
#include <QtQml/qqmlregistration.h>

class Glyph//: public QObject
{
    // Q_OBJECT
    // QML_ELEMENT
public:
    Glyph(uint16_t _code,
          const QString &_bA,
          const QString &_desc = "",
          QObject *parent = nullptr);

    Glyph(const Glyph &_other);
    void operator=(const Glyph &_other);

    uint16_t getCode() const { return m_code; }
    QString getDescription() const { return m_description; }
    QString getByteArray() const { return m_byteArray; }

    QJsonObject toJsonObject();
    static std::tuple<Glyph, bool> fromJsonObject(const QJsonObject &jsonObj);

private:
    uint16_t m_code;
    QString m_description;
    QString m_byteArray;
};

class GlyphData : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
public:
    enum GlyphRoles {
        CodeRole = Qt::UserRole + 1,
        DescRole,
        ByteArrayRole
    };

    GlyphData(QObject *parent = nullptr);

    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    Q_INVOKABLE void addNewData(const Glyph &glyph);
    Q_INVOKABLE void addNewData(uint16_t _code,
                                const QString &_bA,
                                const QString &_desc = "");

    Q_INVOKABLE bool exportModelToJson(int rows, int cols, QString filename);
    Q_INVOKABLE bool loadModelFromFile(QString filename);

protected:
    QHash<int, QByteArray> roleNames() const override;
private:
    QList<Glyph> m_glyphs;
};

#endif // GLYPHDATA_H
