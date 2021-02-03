#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


INSTANCE_METADATA_ATTRIBUTES="http://metadata.google.internal/computeMetadata/v1/instance/attributes/"
KO_DOWNLOADS=$(curl "${INSTANCE_METADATA_ATTRIBUTES}/notebook-disable-downloads" -H "Metadata-Flavor: Google")
KO_NBCONVERT=$(curl "${INSTANCE_METADATA_ATTRIBUTES}/notebook-disable-nbconvert" -H "Metadata-Flavor: Google")

export USER="jupyter"

function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  exit 1
}

function disable_downloads() {
  echo "---------------------------------"
  echo "Creating ForbidFilesHandler class"
  echo "---------------------------------"
  cat <<END >/home/${USER}/.jupyter/handlers.py
from tornado import web
from notebook.base.handlers import IPythonHandler

class ForbidFilesHandler(IPythonHandler):
  @web.authenticated
  def head(self, path):
    self.log.info("HEAD: File download forbidden.")
    raise web.HTTPError(403)

  @web.authenticated
  def get(self, path, include_body=True):
    self.log.info("GET: File download forbidden.")
    raise web.HTTPError(403)

END

  echo "--------------------------------"
  echo "Override the files_handler_class"
  echo "--------------------------------"
  cat <<END >>/home/${USER}/.jupyter/jupyter_notebook_config.py
import os, sys
sys.path.append('/home/${USER}/.jupyter/')
import handlers
c.ContentsManager.files_handler_class = 'handlers.ForbidFilesHandler'
c.ContentsManager.files_handler_params = {}

# prevent export/printing of calculated values that likely have PII
c.TemplateExporter.exclude_input_prompt = True
c.TemplateExporter.exclude_output = True

END

}

function disable_nbconvert() {
  # nbconvert configuration can be altered to prevent output from being stored locally/exported
  pip uninstall nbconvert
}

function main() {

  echo "Checking if must disable downloads..."
  if [[ "${KO_DOWNLOADS}" == 'true' ]]; then
    echo "Calling disable_downloads..."
    disable_downloads || echo 'Error when disabling downloads.'
  fi

  echo "Checking if must uninstall nbconvert..."
  if [[ "${KO_NBCONVERT}" == 'true' ]]; then
    echo "Calling disable_nbconvert..."
    disable_nbconvert || echo 'Error when uninstalling nbconvert.'
  fi

  echo "Check if must restart jupyter.service..."
  if [ "${KO_DOWNLOADS}" == 'true' ] || [ "${KO_NBCONVERT}" == 'true' ]; then
    echo "Try to restart jupyter.service..."
    systemctl restart jupyter.service || echo 'Error restarting jupyter.service.'
  fi

}

main

