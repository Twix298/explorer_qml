#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <QMutex>

struct Copied {
    QString sourceDir;
    QStringList _bufferFiles;
    QStringList _bufferDirs;
};

class DirectoryModel;
class FileManager : public QObject
{
    Q_OBJECT
public:
    explicit FileManager(DirectoryModel *directoryModel, QObject *parent = nullptr);
    void clearBufferFiles();


public slots:
    void startProcessing();
    void copyAsync(const QString &path, const QString &source);
    void removeAsync(const QString &path);
    void pasteAsync(const QString &path);
    void cutAsync(const QString &path, const QString &source);
    void copy(const QString &path, const QString &source);
    void remove(const QString &path);
    bool paste(const QString &destination);
    void cut(const QString &path, const QString &source);
    void runTerminal(const QString &path);

signals:

private:
    DirectoryModel *_directoryModel = nullptr;
    QList<QString> _bufferFiles;
    QList<QString> _bufferDirs;
    Copied copyStruct;
    QMutex _mutex;
};

#endif // FILEMANAGER_H
