echo "Usage: sh render.sh [publish]"
GUIDES=..
# git clone http://github.com/jexp/neo4j-guides $GUIDES

function render {
$GUIDES/run.sh index.adoc index.html +1 "$@"
$GUIDES/run.sh exercises.adoc exercises.html +1 "$@"
$GUIDES/run.sh fecimport.adoc fecimport.html +1 "$@"
$GUIDES/run.sh legis-graph-fec.adoc legisgraphfec.html +1 "$@"
$GUIDES/run.sh legis-graph-import.adoc legisgraphimport.html +1 "$@"
$GUIDES/run.sh legis-graph.adoc legisgraph.html +1 "$@"
$GUIDES/run.sh graphalgorithms.adoc graphalgorithms.html +1 "$@"
$GUIDES/run.sh legis-graph-export-dq.adoc export.html +1 "$@"
$GUIDES/run.sh data-load-overview.adoc dataloadoverview.html +1 "$@"
$GUIDES/run.sh fec-import-exerise-answers.adoc fecimportanswers.html +1 "$@"

}

# -a env-training is a flag to enable full content, if you comment it out, the guides are rendered minimally e.g. for a presentation
if [ "$1" == "publish" ]; then
  URL=guides.neo4j.com/legisgraph
  render http://$URL -a csv-url=https://dl.dropboxusercontent.com/u/67572426/ -a env-training
  s3cmd put --recursive -P *.html img s3://${URL}/
  s3cmd put -P index.html s3://${URL}

  URL=guides.neo4j.com/legisgraph/file
  render http://$URL -a env-training -a csv-url=file:///
  s3cmd put --recursive -P *.html img s3://${URL}/
  s3cmd put -P index.html s3://${URL}
  echo "Publication Done"
else
  URL=localhost:8001/legis-graph
# copy the csv files to $NEO4J_HOME/import
  render http://$URL -a csv-url=file:/// -a env-training
  echo "Starting Websever at $URL Ctrl-c to stop"
  python $GUIDES/http.py
fi