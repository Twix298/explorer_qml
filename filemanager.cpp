#include "filemanager.h"
#include <QFileInfo>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QThread>
#include "directorymodel.h"
#include <QVector>
#include <QProcess>


FileManager::FileManager(DirectoryModel *directoryModel, QObject *parent) :
    QObject(parent), _directoryModel(directoryModel)
{

}

void FileManager::copy(const QString &path, const QString &source) {

    copyStruct._bufferDirs.clear();
    copyStruct._bufferFiles.clear();
    copyStruct.sourceDir = path;
    QString copyFile = path + "/" + source;
    QStringList stack;
    stack.push_front(copyFile);

    while (!stack.isEmpty()) {
        QString currentPath = stack.front();
        stack.pop_front();
        QDir currentDir(currentPath);

        if (QFileInfo(currentPath).isDir()) {
            auto str = currentPath;
            copyStruct._bufferDirs.append(str.remove(0, copyStruct.sourceDir.length()));
            QStringList fileList = currentDir.entryList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot | QDir::Hidden | QDir::System);

            foreach (const QString &file, fileList) {
                const QString filePath = currentPath + "/" + file;

                if (QFileInfo(filePath).isDir()) {
                    stack.push_front(filePath);  // Добавляем в стек для след операций
                } else {
                    copyStruct._bufferFiles.push_back(filePath);
                }
            }
        } else {
            copyStruct._bufferFiles.push_back(currentPath);
        }
    }
}

void FileManager::remove(const QString &path)
{

    QDir dir(path);

    if (!dir.exists()) {
        if(QFile(path).exists()) {
            QFile::remove(path);
        }
        else {
            qWarning() << "Path does not exist:" << path;
        }
        return;
    }

    QStringList itemList = dir.entryList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot | QDir::Hidden | QDir::System);

    foreach (const QString &item, itemList) {
        const QString itemPath = path + "/" + item;

        if (QFileInfo(itemPath).isDir()) {
            remove(itemPath);
        } else {
            // Удаляем файлы
            if (!QFile::remove(itemPath)) {
                qWarning() << "Failed to remove item:" << itemPath;
            }
        }
    }

    if (dir.exists() && !dir.removeRecursively() && !QFile::remove(path)) {
        qWarning() << "Failed to remove item:" << path;
    }
}

bool FileManager::paste(const QString &destination)
{
    if(!copyStruct._bufferDirs.empty()) {
        foreach(const QString &source,  copyStruct._bufferDirs) {
            QFileInfo fileInfo(source);
            QDir path (destination + source);
            if(!path.exists()) {
                path.mkpath(".");
            }
        }
    }
    foreach (QString source, copyStruct._bufferFiles) {
            QFileInfo fileInfo(source);
            QString destFilePath = (destination + source.remove(0, copyStruct.sourceDir.length()));
            int lastSlashIndex = source.lastIndexOf('/');
            auto dir = source.left(lastSlashIndex);
            if (!QFile::copy((fileInfo.absolutePath() + "/" +fileInfo.fileName()), (destination + source)))
                return false;
        }
        _bufferFiles.clear();

        return true;
}

void FileManager::cut(const QString &path, const QString &source)
{
    copy(path, source);
    auto fullPath = path + "/" +source;

}

void FileManager::runTerminal(const QString &path)
{
       QProcess consoleProcess;;
       consoleProcess.startDetached("x-terminal-emulator");
}

void FileManager::clearBufferFiles()
{
    _bufferFiles.clear();
}

void FileManager::startProcessing()
{
    qDebug() << "start";
}

void FileManager::copyAsync(const QString &path, const QString &source)
{
    QMutexLocker locker(&_mutex);
    QMetaObject::invokeMethod(this, "copy", Qt::QueuedConnection, Q_ARG(QString, path), Q_ARG(QString, source));
}

void FileManager::removeAsync(const QString &path)
{
    QMutexLocker locker(&_mutex);
    QMetaObject::invokeMethod(this, "remove", Qt::QueuedConnection, Q_ARG(QString, path));
}

void FileManager::pasteAsync(const QString &path)
{
    QMutexLocker locker(&_mutex);
    QMetaObject::invokeMethod(this, "paste", Qt::QueuedConnection, Q_ARG(QString, path));
}

void FileManager::cutAsync(const QString &path, const QString &source)
{
    QMutexLocker locker(&_mutex);
    QMetaObject::invokeMethod(this, "cut", Qt::QueuedConnection, Q_ARG(QString, path), Q_ARG(QString, source));
}
