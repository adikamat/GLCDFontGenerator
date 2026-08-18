#include "glyphdata.h"

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

QHash<int, QByteArray> GlyphData::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[CodeRole] = "code";
    roles[DescRole] = "description";
    roles[ByteArrayRole] = "byteArray";
    return roles;
}



