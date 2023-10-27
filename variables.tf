variable "release" {
  type        = string
  description = <<-EOT
    The release channel version of RKE2 to install.
    This should match the release version of the files in the remote directory.
  EOT
}
variable "role" {
  type        = string
  description = <<-EOT
    The kubernetes role of the server to install RKE2 on.
    May be 'server' or 'agent', defaults to 'server'.
  EOT
  default     = "server"
}
variable "local_file_path" {
  type        = string
  description = <<-EOT
    The path to the directory on the machine running Terraform with the files to use.
    If left empty, the root module path + rke2 will be used. eg. '~/root/module/path/rke2'
    The module will copy the files in the given directory to the remote server.
    Different install methods have different requirements: for rpm install, you don't need to include any files.
    Place your rke2 configs here, make sure they have .yaml file endings.
    For 'tar' install method, files must match expected file names for the installer to succeed:
      "rke2-images.<system>-<arch>.tar.gz",
      "rke2.<system>-<arch>.tar.gz",
      "sha256sum-<arch>.txt",
      "install.sh"
  EOT
}
variable "remote_file_path" {
  type        = string
  description = <<-EOT
    The path to the directory for the files on the remote server. eg. "/tmp/rke2"
    Files must match expected file names:
      "rke2-images.<system>-<arch>.tar.gz",
      "rke2.<system>-<arch>.tar.gz",
      "sha256sum-<arch>.txt",
      "install.sh",
    The user specified in the ssh_user variable must have read and write permissions to this directory.
    The default value is "/home/<ssh_user>/rke2".
  EOT
  default     = ""
}
variable "remote_workspace" {
  type        = string
  description = <<-EOT
    The path to a directory where the module can store temporary files and execute scripts. eg. "/var/tmp"
    The user specified in the ssh_user variable must have read, write, and execute permissions to this directory.
    If left blank "/home/<ssh_user>" will be used.
  EOT
  default     = "~"
}
variable "ssh_ip" {
  type        = string
  description = <<-EOT
    The IP address of the server to install RKE2 on.
    We will attempt to open an ssh connection on this IP address.
    Ssh port must be open and listening, and the user must have sudo/admin privileges.
    This script will only run the install script, please ensure that the server is ready.
  EOT
}
variable "ssh_user" {
  type        = string
  description = <<-EOT
    The user to log into the server to install RKE2 on.
    We will attempt to open an ssh connection with this user.
    The user must have sudo/admin privileges.
    This script will only run the install script, please ensure that the server is ready.
  EOT
}
variable "identifier" {
  type        = string
  description = <<-EOT
    A unique identifier for the server to install RKE2 on.
    This is used to align the resources in this module with your server lifecycle.
    If this value is changed, the resources will be recreated.
    This allows you to manage your server lifecycle separate from your RKE2 lifecycle.
  EOT
}
variable "retrieve_kubeconfig" {
  type        = bool
  description = <<-EOT
    Whether or not to retrieve the kubeconfig from the server.
    If this is set to true, the module will retrieve the kubeconfig from the server and write it to a file.
    The file will be named "kubeconfig-<identifier>.yaml" and will be written to the root directory.
    The module replaces the default IP (127.0.0.1) with the IP address of the server (ssh_ip).
    If this is set to false, the module will not retrieve the kubeconfig from the server.
  EOT
  default     = false
}
variable "install_method" {
  type        = string
  description = <<-EOT
    The install method to set when running the install script.
    This should be one of "tar" or "rpm".
    The default is tar, which assumes you are downloading the files and want to copy them over to the remote server.
    This is the most contained method, and does not require public internet access on the remote server.
    If you are using the rpm install method, your server will need to be able to access the internet to download the rpms.
  EOT
  default     = "tar"
}
variable "server_prep_script" {
  type        = string
  description = <<-EOT
    The content of a script to run on the server before installing RKE2.
    This script will be run as root.
    This is useful for installing dependencies or configuring the server.
    This can help mitigate issues like those found in https://docs.rke2.io/known_issues
  EOT
  default     = ""
}
variable "start" {
  type        = bool
  description = <<-EOT
    Should the module start rke2.
    There are some limited situations where we want to install rke2, but not start it.
    Starting rke2 is the default behavior.
  EOT
  default     = true
}
