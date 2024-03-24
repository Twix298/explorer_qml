#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <directorymodel.h>
#include "filemanager.h"
#include <QApplication>
#include <QtQml>
#include <QQmlContext>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    qmlRegisterType<DirectoryModel>("DirectoryViewer", 1, 0, "DirectoryModel");
    QThread *threadFileManager = new QThread();
    DirectoryModel *directoryModel = new DirectoryModel();
    FileManager *fileManager = new FileManager(directoryModel);
    engine.rootContext()->setContextProperty("FileManager", fileManager);
    engine.rootContext()->setContextProperty("DirectoryModel", directoryModel);

    fileManager->moveToThread(threadFileManager);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    threadFileManager->start();
    engine.load(url);


    return app.exec();
}
