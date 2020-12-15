#include <QFileSystemWatcher>
#include <QObject>
#include <QString>

class QJSEngine;
class QQmlEngine;

/**
 * @brief A simple singleton helper class
 *
 */
class Helper : public QObject {
    Q_OBJECT

public:
    Q_PROPERTY(QString latestDotFile READ latestDotFile NOTIFY pipelineDotChanged)
    Q_PROPERTY(QString pipelineBlockDiagram READ pipelineBlockDiagram NOTIFY pipelineBlockDiagramChanged)

    /**
     * @brief Return singleton pointer
     *
     * @return Helper*
     */
    static Helper *self() {
        static Helper helper;
        return &helper;
    }

    /**
     * @brief Return a pointer of this singleton to the qml register function
     *
     * @param engine
     * @param scriptEngine
     * @return QObject*
     */
    static QObject* qmlSingletonRegister(QQmlEngine* engine, QJSEngine* scriptEngine);

    QString temporaryPath() const;

    QString latestDotFile() const;

    QString pipelineBlockDiagram() const;

Q_SIGNALS:
    void pipelineDotChanged();
    void pipelineBlockDiagramChanged();

private:
    /**
     * @brief Construct a new Helper object
     */
    Helper();

    QFileSystemWatcher _filesystemWatcher;
    QString _latestDotFile;
    QString _pipelineBlockDiagram;
    QString _temporaryPath;
};