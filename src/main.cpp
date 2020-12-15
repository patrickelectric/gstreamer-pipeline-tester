#include <QApplication>
#include <QQmlApplicationEngine>

#include "helper.h"

int main(int argc, char *argv[]) {
    qmlRegisterSingletonType<Helper>("Helper", 1, 0, "Helper", Helper::qmlSingletonRegister);

    QGuiApplication app(argc, argv);

    // Need to be done after QGuiApplication
    qputenv("GST_DEBUG_DUMP_DOT_DIR", Helper::self()->temporaryPath().toLatin1());

    QQmlApplicationEngine appEngine(QUrl("qrc:/main.qml"));
    return app.exec();
}