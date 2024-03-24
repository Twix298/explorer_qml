#include "directorymodel.h"
#include "filemanager.h"
#include <QDebug>
#include <QMimeDatabase>
#include <QMimeType>
#include <QDateTime>
#include <QDir>

#include <QThread>


DirectoryModel::DirectoryModel(QObject *parent) :  QAbstractTableModel(parent)
{
    moveToHomeDir();

}

QString DirectoryModel::getFileMimeType(const QString &filePath) const
{
    QFile file(filePath);

        if (!file.exists()) {
            qDebug() << "File does not exist:" << filePath;
            return QString();
        }

        QMimeDatabase mimeDatabase;
        QMimeType mimeType = mimeDatabase.mimeTypeForFile(filePath);

        return mimeType.name().split("/").last();
}

qint64 DirectoryModel::getFileSize(const QString &filePath) const
{
    QFile file(filePath);

    if (!file.exists()) {
        qDebug() << "File does not exist:" << filePath;
        return -1;
    }

    QFileInfo fileInfo(file);
    return fileInfo.size();
}

QString DirectoryModel::getFileLastModified(const QString &filePath) const
{
    QFile file(filePath);

    if (!file.exists()) {
        qDebug() << "File does not exist:" << filePath;
        return QString();
    }

    QFileInfo fileInfo(file);
    return fileInfo.lastModified().toString(Qt::TextDate);
}

void DirectoryModel::reverse()
{
    QDir currentDir(_currentPath);
    if (currentDir.cdUp()) {
        qDebug() << "Успешно перешли в родительскую директорию.";
        qDebug() << "Текущая директория: " << currentDir.absolutePath();
        _currentPath = currentDir.absolutePath();
        scanDirectory(_currentPath);
        updateModel();
    } else {
        qWarning() << "Не удалось перейти в родительскую директорию.";
    }
}

bool DirectoryModel::isDir(const QString &path)
{
    QFileInfo info(path);
    return info.isDir();
}

QMap<QString, ulong> DirectoryModel::getFiles() const
{
    return _files;
}

QString DirectoryModel::getCurrentNameFile(const int index)
{
    return std::next(_files.begin(), index).key();
}

QString DirectoryModel::getCurrentPath() const
{
    return _currentPath;
}

FileManager *DirectoryModel::getFileManager() const
{
    return _fileManager;
}

void DirectoryModel::scanDirectory(const QString &path)
{
    QDir directory(path);
    if (!directory.exists())
    {
        qWarning() << "Directory not found:" << path;
        return;
    }
    _files.clear();

    QFileInfoList fileList = directory.entryInfoList(QDir::Files);
    for (const QFileInfo &fileInfo : fileList)
    {
        _files.insert(fileInfo.fileName(), 0);
    }

    QFileInfoList dirList = directory.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QFileInfo &dirInfo : dirList)
    {
        _files.insert(dirInfo.fileName(), 1);
    }
}

void DirectoryModel::updateModel()
{
    scanDirectory(_currentPath);
    beginResetModel();
    _files;
    endResetModel();
}

void DirectoryModel::moveForward(const QString &file)
{
    _currentPath = _currentPath + "/" + file;
    updateModel();
    emit directoryChanged();
}

void DirectoryModel::moveToHomeDir()
{
    _currentPath = QDir::homePath();
    scanDirectory(_currentPath);
    updateModel();
}

int DirectoryModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return _files.size();
}

int DirectoryModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return roleNames().size();
}

QVariant DirectoryModel::data(const QModelIndex &index, int role) const
{
    QVariant variant;
    if(!index.isValid()) {
        return QVariant();
    }
    const int row = index.row();
    switch (role) {
    case NAME: {
        variant = (_files.constBegin() + index.row()).key();
        break;
    }
    case TYPE: {
        variant = getFileMimeType(_currentPath + "/" + (_files.constBegin() + index.row()).key());
        break;
    }
    case SIZE: {
        variant = getFileSize(_currentPath + "/" + (_files.constBegin() + index.row()).key());
        break;
    }
    case LASTCHANGE: {
        variant = getFileLastModified(_currentPath + "/" + (_files.constBegin() + index.row()).key());
        break;
    }
    }
    return variant;
}

QHash<int, QByteArray> DirectoryModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(NAME, "name");
    roles.insert(TYPE, "type");
    roles.insert(SIZE, "size");
    roles.insert(LASTCHANGE, "lastchange");
    return roles;
}
