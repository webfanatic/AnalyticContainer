#!/usr/bin/env bash

# run ac_container_example_one via command line
cd /dk/AnalyticContainer
pwd

# cleanup exsinng containers
echo 'cleanup exsinng containers .. ignore errors'
docker rm $(docker ps -a | grep ac_container_example_one)
docker rm $(docker ps -a | grep data_ac_example_one)


#build
echo 'building ac_container_example_one'
sudo docker build -f /dk/AnalyticContainer/ACExampleOne/Dockerfile -t ac_container_example_one .
echo 'building data_ac_example_one'
sudo docker run -d -v /dk/AnalyticContainer/ACExampleOne/docker-share --name="data_ac_example_one" ac_container_example_one:latest
echo 'adding config.json to data_ac_example_one'
sudo docker cp /dk/AnalyticContainer/ACExampleOne/docker-share/config.json data_ac_example_one:/dk/AnalyticContainer/ACExampleOne/docker-share/config.json

#run
echo 'running ac_example_one'
sudo docker run -e CONTAINER_INPUT_CONFIG_FILE_PATH="/dk/AnalyticContainer/ACExampleOne/docker-share" -e CONTAINER_INPUT_CONFIG_FILE_NAME="config.json" -e CONTAINER_OUTPUT_PROGRESS_FILE="progress.json" -e CONTAINER_OUTPUT_LOG_FILE="ac_logger.log" -e INSIDE_CONTAINER_FILE_MOUNT="/dk/AnalyticContainer/ACExampleOne" -e INSIDE_CONTAINER_FILE_DIRECTORY="/dk/AnalyticContainer/ACExampleOne/docker-share" --volumes-from data_ac_example_one ac_container_example_one:latest
sudo docker cp data_ac_example_one:/dk/AnalyticContainer/ACExampleOne/docker-share/progress.json /dk/AnalyticContainer/ACExampleOne/docker-share/progress.json
sudo docker cp data_ac_example_one:/dk/AnalyticContainer/ACExampleOne/docker-share/ac_logger.log /dk/AnalyticContainer/ACExampleOne/docker-share/ac_logger.log

echo 'completed run data_ac_example_one, viewing data in data_ac_example_one'
sudo ls -al `docker inspect --format='{{(index .Mounts 0).Source}}' data_ac_example_one`

echo 'view file system data_ac_example_one'
ls -als /dk/AnalyticContainer/ACExampleOne/docker-share/

echo 'Note: the two above should be the same'