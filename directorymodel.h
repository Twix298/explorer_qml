#ifndef DIRECTORYMODEL_H
#define DIRECTORYMODEL_H

#include <QObject>
#include <QAbstractTableModel>

class FileManager;

class DirectoryModel : public QAbstractTableModel
{
    Q_OBJECT
public:
    enum FieldRoles {
        NAME = Qt::UserRole + 1,
        TYPE,
        SIZE,
        LASTCHANGE
    };
    Q_ENUM(FieldRoles)
    Q_PROPERTY(QString currentPath READ getCurrentPath);

    explicit DirectoryModel(QObject *parent = nullptr);
    QString getFileMimeType(const QString &filePath) const;
    qint64 getFileSize(const QString &filePath) const ;
    QString getFileLastModified(const QString &filePath) const;
    Q_INVOKABLE FileManager *getFileManager() const;

    Q_INVOKABLE QString getCurrentPath() const;

    Q_INVOKABLE QMap<QString, ulong> getFiles() const;
    Q_INVOKABLE QString getCurrentNameFile(const int index);

public slots:
    void scanDirectory(const QString &path);
    void updateModel();
    void moveForward(const QString &file);
    void moveToHomeDir();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void reverse();
    bool isDir(const QString &path);
signals:
    void directoryChanged();
private:
    QString _currentPath;
    QMap<QString, ulong> _files; // 0 - файл, 1 - директория
    QThread *_fileManagerThread;
    FileManager *_fileManager;
};

#endif // DIRECTORYMODEL_H
