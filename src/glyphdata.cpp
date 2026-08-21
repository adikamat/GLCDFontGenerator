#include "glyphdata.h"
#include <QJsonArray>
#include <QFile>

#define JSON_KEY_CODE "Code"
#define JSON_KEY_DESC "Description"
#define JSON_KEY_BA "ByteArray"
#define JSON_KEY_ROWS "NumRows"
#define JSON_KEY_COLS "NumCols"
#define JSON_KEY_GLYPHS "Glyphs"

Glyph::Glyph(uint16_t _code,
             const QString &_bA,
             const QString &_desc,
             QObject *parent)
    : /*QObject{parent}
    ,*/ m_code{_code}
    , m_description{_desc}
    , m_byteArray{_bA}
{}

Glyph::Glyph(const Glyph &_other)
    : m_code{_other.getCode()}
    , m_description{_other.getDescription()}
    , m_byteArray{_other.getByteArray()}
{}

void Glyph::operator=(const Glyph &_other)
{
    m_code = _other.getCode();
    m_description = _other.getDescription();
    m_byteArray = _other.getByteArray();
}

QJsonObject Glyph::toJsonObject()
{
    return {
        {JSON_KEY_CODE, getCode()},
        {JSON_KEY_DESC, getDescription()},
        {JSON_KEY_BA, getByteArray()}
    };
}

std::tuple<Glyph, bool> Glyph::fromJsonObject(const QJsonObject &jsonObj)
{
    auto codeIt = jsonObj.find(JSON_KEY_CODE);
    auto descIt = jsonObj.find(JSON_KEY_DESC);
    auto bAIt = jsonObj.find(JSON_KEY_BA);

    if((codeIt != jsonObj.end())
        && (descIt != jsonObj.end())
        && (bAIt != jsonObj.end()))
    {
        uint16_t code = static_cast<uint16_t>(codeIt.value().toInteger());
        QString desc = descIt.value().toString();
        QString bA = bAIt.value().toString();
        return std::make_tuple<Glyph, bool>({code, bA, desc}, true);
    }
    else
    {
        qWarning("Invalid JSON found %s", QJsonValue(jsonObj).toString().toStdString().c_str());
        return std::make_tuple<Glyph, bool>({65535, "", ""}, false);
    }
}

GlyphData::GlyphData(QObject *parent)
    : QAbstractListModel(parent)
{}

int GlyphData::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_glyphs.count();
}

QVariant GlyphData::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_glyphs.count())
        return QVariant();

    const Glyph &glyph = m_glyphs[index.row()];
    switch(role)
    {
    case CodeRole:
        return glyph.getCode();
    case DescRole:
        return glyph.getDescription();
    case ByteArrayRole:
        return glyph.getByteArray();
    default:
        return QVariant();
    }
}

void GlyphData::addNewData(const Glyph &glyph)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_glyphs << glyph;
    endInsertRows();
}

void GlyphData::addNewData(uint16_t _code, const QString &_bA, const QString &_desc)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    qDebug() << "Data:" << _code;
    m_glyphs << Glyph{_code, _bA, _desc};
    endInsertRows();
}

bool GlyphData::exportModelToJson(int rows, int cols, QString filename)
{
    QJsonArray glyphModelJson;
    for(auto &item : m_glyphs)
    {
        glyphModelJson.push_back(item.toJsonObject());
    }
    QFile saveFile(filename);

    if (!saveFile.open(QIODevice::WriteOnly)) {
        qWarning("Couldn't open save file.");
        return false;
    }

    QJsonObject fontGlyphMap{{JSON_KEY_ROWS, rows},
                             {JSON_KEY_COLS, cols},
                             {JSON_KEY_GLYPHS, glyphModelJson}};

    saveFile.write(QJsonDocument(fontGlyphMap).toJson());

    return true;
}

bool GlyphData::loadModelFromFile(QString filename)
{
    QFile loadFile("Export.json");

    if (!loadFile.open(QIODevice::ReadOnly)) {
        qWarning("Couldn't open save file.");
        return false;
    }

    QByteArray saveData = loadFile.readAll();

    QJsonDocument loadDoc(QJsonDocument::fromJson(saveData));

    QJsonObject jsonObj(loadDoc.object());
    auto arrayIt = jsonObj.find(JSON_KEY_GLYPHS);
    if(arrayIt == jsonObj.end())
    {
        return false;
    }
    else
    {
        Glyph g{65535, "", ""};
        bool valid = false;
        QJsonArray glyphs = arrayIt.value().toArray();
        auto glyphIt = glyphs.begin();
        beginResetModel();
        while(glyphIt != glyphs.end())
        {
            std::tie<Glyph, bool>(g, valid) = Glyph::fromJsonObject((*glyphIt).toObject());
            if(valid)
            {
                m_glyphs.push_back(g);
            }
            glyphIt++;
        }
        endResetModel();
    }
    return true;
}

QHash<int, QByteArray> GlyphData::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[CodeRole] = "code";
    roles[DescRole] = "description";
    roles[ByteArrayRole] = "byteArray";
    return roles;
}



