#!/usr/bin/env bash

# run ac_check_table_and_email via command line
cd /dk/AnalyticContainer
pwd

# cleanup exsinng containers
echo 'cleanup exsinng containers .. ignore errors'
docker rm $(docker ps -a | grep ac_check_table_and_email)
docker rm $(docker ps -a | grep data_ac_check_table_and_email)


#build
echo 'building ac_check_table_and_email'
sudo docker build  -f  /dk/AnalyticContainer/CheckTableAndEmail/Dockerfile -t ac_check_table_and_email .
echo 'building data_ac_check_table_and_email'
sudo docker run -d -v /dk/AnalyticContainer/CheckTableAndEmail/docker-share --name="data_ac_check_table_and_email" ac_check_table_and_email:latest
echo 'adding config.json to data_ac_check_table_and_email'
sudo docker cp /dk/DKModules/tests/json/check-table-send-email-container/container-node/docker-share/config.json data_ac_check_table_and_email:/dk/AnalyticContainer/CheckTableAndEmail/docker-share/config.json
sudo docker cp /dk/DKModules/tests/json/check-table-send-email-container/container-node/docker-share/check-table-email-template.html data_ac_check_table_and_email:/dk/AnalyticContainer/CheckTableAndEmail/docker-share/check-table-email-template.html

#run
echo 'running ac_check_table_and_email'
sudo docker run -e CONTAINER_INPUT_CONFIG_FILE_PATH="/dk/DKModules/tests/json/check-table-send-email-container/container-node/docker-share" -e CONTAINER_INPUT_CONFIG_FILE_NAME="config.json" -e CONTAINER_OUTPUT_PROGRESS_FILE="progress.json" -e CONTAINER_OUTPUT_LOG_FILE="ac_logger.log" -e INSIDE_CONTAINER_FILE_MOUNT="/dk/AnalyticContainer/CheckTableAndEmail" -e INSIDE_CONTAINER_FILE_DIRECTORY="/dk/AnalyticContainer/CheckTableAndEmail/docker-share" --volumes-from data_ac_check_table_and_email ac_check_table_and_email:latest

echo 'copying volume back .. not sure why this does not happen automatically'
sudo docker cp data_ac_check_table_and_email:/dk/AnalyticContainer/CheckTableAndEmail/docker-share/progress.json /dk/AnalyticContainer/CheckTableAndEmail/docker-share/progress.json
sudo docker cp data_ac_check_table_and_email:/dk/AnalyticContainer/CheckTableAndEmail/docker-share/ac_logger.log /dk/AnalyticContainer/CheckTableAndEmail/docker-share/ac_logger.log

echo 'completed run ac_check_table_and_email, viewing data in data_ac_check_table_and_email'
sudo ls -als `docker inspect --format='{{(index .Mounts 0).Source}}' data_ac_check_table_and_email`

echo 'view file system data_ac_check_table_and_email'
ls -als /dk/AnalyticContainer/CheckTableAndEmail/docker-share/

echo 'the two above should be the same'