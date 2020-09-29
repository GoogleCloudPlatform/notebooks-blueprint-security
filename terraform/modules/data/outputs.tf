/*
Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Adding these outputs allows other modules as well as the calling
// terraform script to access the attributes of these modules.

// bucket used for ETL pipeline created by this module
output "bkt_p_data_etl" {
  value = google_storage_bucket.bkt_p_data_etl.self_link
}

output "bkt_p_bootstrap_notebook" {
  value = google_storage_bucket.bkt_p_bootstrap_notebooks
}

// // provides the name to append to the gs:// in Notebook postscript metadata value
// output "bkt_p_bootstrap_notebook-postscript" {
//   value = google_storage_bucket_object.notebook-postscript.name
// }
