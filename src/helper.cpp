#include "helper.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QQmlEngine>
#include <QStandardPaths>

#include <tuple>

#include <graphviz/gvc.h>

Helper::Helper()
    : QObject(nullptr)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

    auto folderName = QFileInfo(QCoreApplication::applicationFilePath()).fileName();
    _temporaryPath = QDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation)).absoluteFilePath(folderName);
    auto dir = QDir(_temporaryPath);
    auto result = dir.exists() || dir.mkdir(".");
    if (!result) {
        qWarning() << "Failed to create for dot files:" << _temporaryPath;
        return;
    }

    qDebug() << "Using temporary folder:" << _temporaryPath;

    _filesystemWatcher.addPath(_temporaryPath);
    QObject::connect(&_filesystemWatcher, &QFileSystemWatcher::directoryChanged, [this](const QString& path){
        auto dir = QDir(path);
        auto files = dir.entryList({"*.dot"}, QDir::Files);

        auto latestFile = std::tuple<QString, QDateTime>{{}, QDateTime::fromMSecsSinceEpoch(0)};
        for (auto file : files) {
            auto fileInfo = QFileInfo(dir.absoluteFilePath(file));
            auto time = fileInfo.lastModified();
            if (std::get<1>(latestFile) < time) {
                latestFile = {fileInfo.absoluteFilePath(), time};
            }
        }

        _latestDotFile = std::get<0>(latestFile);
        _pipelineBlockDiagram = _latestDotFile + ".svg";

        { // Thanks to: https://stackoverflow.com/a/51990640/7988054
            GVC_t* gvc = gvContext();
            FILE* file = fopen(_latestDotFile.toStdString().c_str(), "r");
            Agraph_t* graph = agread(file, 0);
            gvLayout(gvc, graph, "dot");
            gvRender(gvc, graph, "svg", fopen(_pipelineBlockDiagram.toStdString().c_str(), "w"));
            gvFreeLayout(gvc, graph);
            agclose(graph);
            gvFreeContext(gvc);
        }

        emit pipelineDotChanged();
        emit pipelineBlockDiagramChanged();
    });
}

QObject* Helper::qmlSingletonRegister(QQmlEngine* engine, QJSEngine* scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return self();
}

QString Helper::temporaryPath() const
{
    return _temporaryPath;
}

QString Helper::latestDotFile() const
{
    return _latestDotFile;
}

QString Helper::pipelineBlockDiagram() const
{
    return _pipelineBlockDiagram;
}