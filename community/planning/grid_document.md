# Grid Document
<!--
  Copyright 2022 Bitwise IO, Inc.
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

- Feature Name: Grid Document
- Start Date: 2022-08-01
- RFC PR:
- Hyperledger Grid Issue:

## Summary
[summary]: #summary

Grid Document allows for the sharing of arbitrary documents between parties on a
Grid network. Documents are managed in a simple filesystem-like model with a
single layer of uniquely named folders and the ability to upload uniquely named
documents to those locations.

## Motivation
[motivation]: #motivation

Grid Document supports flexible prototyping of new data concepts using a document
metaphor. Exchanging data using document records on a Grid network may be an
attractive precursor to designing and implementing standards-based or new custom
data models and workflows for the specific records types. In addition, Grid
Document enables use cases where document sharing is the end goal.

## Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

### Entities

Grid Document persists and allows access to local files as opaque objects,
organized into folders.

A file is referenced using its name and its parent folder name. The contents of
the file, encoded by the client, are stored in state as bytes.

A folder will have a list of names, referencing the files it contains. Folders
also have a unique name property.

### Transactions

In order to add a file or folder to state, a transaction must be submitted. Grid
Document defines three transactions, used to create a file or delete a file or
delete a folder. Currently, no permissions are enforced when handling state
objects. The next section explains how Grid Document may be extended in the
future to enforce permissioning.

#### Create a folder
The operation to create a folder will take in a unique folder name and add it
to state. If the folder already exists, the transaction is invalid.

#### Delete a folder
The operation to delete a folder will take in the folder name and remove it
from state.

#### Create a file
The operation to create a file will take in a destination folder, file name, and
file contents. The file will be stored in state in relation to the destination
folder.

#### Delete a file
The operation to delete a file will take in the file name and the name of its
parent folder. The file name will be removed from the parent folder and the
file removed from state.

## Reference-level explanation
[reference-level-explanation]: #reference-level-explanation

### State

#### File Representation

The primary object that may be stored in state is a “File”, which represents an
opaque version of the local file with a name and contents. As file contents are
stored and handled as bytes, Grid Document cannot see any file details beyond
the designated name. This file is addressed in state in relation to a folder.
The transaction responsible for creating a file must ensure the name of a new
file is unique within the destination folder.

Grid Document stores objects in state using protobuf message format. Therefore,
the file’s content size is limited to the capacity of its associated data type.
Based on the protocol buffer documentation, `bytes` have a maximum size of 2 GB.
This information and more on protobuf encoding can be found in the
[Protocol Buffer Developer's Guide]
(https://developers.google.com/protocol-buffers/docs/encoding). The
transaction responsible for creating a file must validate the content is not
larger than 2 GB.

A “File” is represented as a protobuf message in state, as follows:
```
message File {
	string name = 1;
	bytes content = 2;
}
```

#### Folder Representation

The other object that may be stored in state is a “Folder”, which holds lists of
files. In the Merkle-Radix state, a folder is represented by its unique name and
a list of the names of the files it contains. The `DocumentRoot` object
represents a list of all the folders in state. The transaction responsible
for creating a folder must validate its name is unique in this list.

To ensure the Merkle-Radix trie does not become overloaded with data,
which leads to more hash collisions and slow state operations, the number of
folders overall and the number of files per folder will be limited. This will
ensure state operations at folder addresses remain manageable. Therefore,
the transaction responsible for creating a folder must validate that state has
not surpassed its maximum folder capacity.  Additionally, there will be a
defined limit to the total amount of files a folder can hold. The transaction
responsible for creating a file must validate the folder has not surpassed its
maximum file capacity.

The protocol buffer representation of DocumentRoot and Folder are as follows:

```
message DocumentRoot {
  repeated Folder folders = 1;
}

message Folder {
  string name = 1;
  repeated string files = 2;
}
```

### Transaction Payloads and Execution

#### DocumentPayload Transaction

DocumentPayload has an enum field, containing the only possible actions, and
fields for each of the associated actions’ payloads. The enum field determines
how the transaction payload will be handled. Only one `Action` variant can be
defined for a payload. Therefore, only one action payload, correlating with the
defined `Action`, is processed in a transaction.

```
message DocumentPayload {
  enum Action {
    UNSET_ACTION = 0;
    FOLDER_CREATE = 1;
    FOLDER_DELETE = 2;
    FILE_CREATE = 3;
    FILE_DELETE = 4;
  }

  Action action = 1;

  FolderCreateAction folder_create = 2;
  FolderDeleteAction folder_delete = 3;
  FileCreateAction file_create = 4;
  FileDeleteAction file_delete = 5;
}
```

#### FolderCreateAction

FolderCreateAction creates a new unique folder in state.

```
message FolderCreateAction {
  string name = 1;
}
```
Validation requirements:
* Folder must not exist in state
* Name must be unique within the DocumentRoot
* Name must not contain any special characters
* Length of DocumentRoot’s `folders` list must not exceed the limit

#### FolderDeleteAction

FolderDeleteAction removes an empty folder from state.

```
message FolderDeleteAction {
  string name = 1;
}
```
Validation requirements:
* Length of the folder’s `files` list must be 0
* Folder must exist in state

#### FileCreateAction

FileCreateAction creates a new file in a specified folder in state, creating the
folder if necessary.

```
message FileCreateAction {
  string folder = 1;
  string name = 2;
  bytes content = 3;
}
```
Validation requirements:
* Name must be unique within the folder
* Name must not contain any special characters
* Length of the folder’s `files` list must not exceed the limit
* Content size must not be over 2 GB

#### FileDeleteAction

FileDeleteAction removes an existing file from state. This transaction is
invalid if the folder or file does not exist in state.

```
message FileDeleteAction {
  string folder = 1;
  string name = 2;
}
```
Validation requirements:
* Folder must exist in state
* File must exist in state

### Document Addressing in the Merkle-Radix State System

Grid Document defines a formula to compute the Merkle-Radix trie address for its
state objects. Merkle-Radix addresses consist of 70 characters. All Grid
addresses are prefixed with the 6-hex-character “621dee” namespace. Grid
Document state is further namespaced with a “07” prefix. All state entries with
an address beginning in “621dee07” are Grid Document objects. The section of
state is further namespaced for folders and files using a 2-hex-character
string. The “00” namespace is reserved for folders and the “01”
namespace is reserved for files.

Grid Document state addresses begin with the previously defined namespaces,
leaving 60 characters to construct. The name of a file or folder will be hashed
and a subset of the first characters of the resulting hash is used for the
remaining address.

The first 10-hex-characters of the SHA-512 hash of the folder name is then
followed by trailing zeroes. The formula to construct a folder’s Merkle-Radix
address follows:

```
“621dee” + “07” + “00” + Sha512(folder_name)[:10] + “000000000000000000000000000000000000000000000000”
 ```

Grid Document allows files to be stored in relation to a folder, similar to
native environments. If a file is stored in relation to a Grid Document folder,
the address constructed will include a hash of both the unique folder and file
name. Similar to how addresses are constructed for folders, a file will contain
the first 10-hex-characters of the hashed folder name. Remaining characters of
the address are pulled from the hashed file name. Therefore, the formula for
creating a Grid Document file follows:

```
“621dee” + “07” + “01” +  Sha512(folder_name)[:10] +  Sha512(file_name)[:10]
```

## Client Designs
[client-designs]: #client-desings

### Command Line Interface

Commands will be added to support creating and accessing files and folders
stored by Grid. Grid Document commands will begin with the `grid-doc` subcommand.

#### **grid doc cp** \[**FLAGS**\] \[**OPTIONS**\] {SOURCE} {DESTINATION}
This command will copy the bytes of a file, decode it to a specified format,
and download the resulting file to a destination folder.

When this command copies to a remote destination, a Sabre transaction is
submitted to create a file.

The cp command will fail in either direction if the destination directory does
not exist.

The command supports file globbing. When specifying multiple local files, normal
shell globbing is used. When specifying multiple remote files, the CLI will
perform globbing against the list of remote files.

##### ARGS
`SOURCE`
: Specify the source file or folder being copied.

`DESTINATION`
: Specify a destination to save the copied contents.

##### EXAMPLES
```
$ grid doc cp \
     remote::/invoices/invoice_01.inv \
     new_invoice.inv
```
The above command will attempt to copy a remote file, `/invoices/invoice_01.inv`,
to a local destination, `new_invoice.inv`.

This command may also be used to copy a local file to a remote location.
```
$ grid doc cp \
     local_file_name.txt \
     remote::/documents
```
The above command will attempt to copy the local file, `local_file_name.txt` to
a remote destination, `/documents`, in Grid Document state.

```
$ grid doc cp \
    *.txt \
    remote::/documents
```
The above command will copy all files in the current directory with the .txt
extension to the remote documents folder.

```
$ grid doc cp \
     * \
     remote::/documents
```

The above command will copy all files in the current directory to the remote
documents folder.

```
$ grid doc cp \
     "remote::/documents/*.txt" \
     local_folder/
```
The above command will copy all files from Grid Document in the documents folder
that have the .txt extension.

#### **grid-doc-mkdir** \[**FLAGS**\] \[**OPTIONS**\] {NAME}

This command will create a folder. The command submits a Sabre transaction,
validated by the Grid Document smart contract, to create a new folder in Grid
Document state.

##### ARGS
`NAME`
: Unique name of the folder to be created

##### EXAMPLES
```
$ grid doc mkdir invoices
```
The above command will attempt to create a folder named “invoices” in Grid
Document state.

#### **grid-doc-ls** \[**FLAGS**\] \[**OPTIONS**\] {REMOTE_DIRECTORY}

This command will list contents in state. Listed contents are limited to a
remote directory, if specified.

A couple hidden aliases should exist for this command: "grid doc list" and
"grid doc dir".

##### ARGS
`REMOTE_DIRECTORY`
: Specify a remote directory to list contents.

##### EXAMPLES
```
$ grid doc ls invoices
```
The above command will list all files in the ‘invoices’ folder in Grid Document
state. The next command will list all folders in Grid Document state.

```
$ grid doc ls
```

#### **grid-doc-rm** \[**FLAGS**\] \[**OPTIONS**\] {FILE}

This command will delete a file. The command submits a Sabre transaction to
delete the file from Grid Document state.

A couple aliases could be provided for this command: "grid doc delete"
and "grid doc del".

This command also supports file globbing.

##### ARGS
`FILE`
: Name of the file to be removed.

##### OPTIONS
`-r`
: Remove the folder recursively, first removing all files in the folder then
the folder itself.

##### EXAMPLES
```
$ grid doc rm \
     /invoices/invoice_01.inv
```

The above command will attempt to delete the remote file, invoice_01.inv,
from the remote folder, /invoices. The following command will attempt to
delete a folder, /invoices.

```
$ grid doc rm \
     /invoices
```

Example 1:

```
$ grid doc rm \
  a_real_folder/a_real_file
```

The above command deletes the file `a_real_file` from the `a_real_folder` folder.

```
$ grid doc rm \
   "a_real_folder/*.txt"
```
The above command deletes all files with the .txt extension from the Grid
Document folder `a_real_folder`.

```
$ grid doc rm \
  “a_real_folder/*”
```

The above command will delete all files from the ‘a_real_folder’ folder,
this is the same action as the `-r` option.

#### **grid-doc-rmdir** \[**FLAGS**\] \[**OPTIONS**\] {FOLDER}

This command will attempt to delete an empty directory. The command submits a
Sabre transaction to delete the folder from Grid Document state.

##### ARGS
`FOLDER`
: Name of the empty folder to be removed.

##### EXAMPLES
The following command will attempt to delete the remote folder, `/invoices`.

```
$ grid doc rmdir \
     invoices
```

### REST API

Grid’s REST API will be extended to include endpoints to access Grid Document
state and to submit transactions. The required endpoints are as follows:

* `GET /docs`

This endpoint will list all folders. The response body will be formatted as a
paginated JSON list.

* `GET /docs/{folder}`

This endpoint will list all files in the specified folder. The response body will
be formatted as a paginated JSON list.

* `POST /docs/{folder}`

This endpoint will accept both JSON- and byte-encoded payloads to create a folder.
The signed batch is then persisted in Grid’s database. Once the batch has been
successfully stored, the endpoint will respond with a JSON-formatted list of the
batch’s identifiers.

* `DELETE /docs/{folder}`

This endpoint will accept both JSON- and byte-encoded payloads to delete a folder.
The signed batch is then persisted in Grid’s database. Once the batch has been
successfully stored, the endpoint will respond with a JSON-formatted list of the
batch’s identifiers.

* `GET /docs/{folder}/{file}`

This endpoint will download the contents of the specified file.

* `POST /docs/{folder}/{file}`

This endpoint will accept both JSON- and byte-encoded payloads to create a file.
The signed batch is persisted in Grid’s database. Once the batch has been
successfully stored, the endpoint will respond with a JSON-formatted list of the
batch’s identifiers.

* `DELETE /docs/{folder}/{file}`

This endpoint will accept both JSON- and byte-encoded payloads to delete a file.
The signed batch is then persisted in Grid’s database. Once the batch has been
successfully stored, the endpoint will respond with a JSON-formatted list of the
batch’s identifiers.

## Future Considerations
[future-considerations]: #future-considerations

Grid Document is intentionally simple to use but may be extended in the future
to support more unique and robust business scenarios. This may include allowing
for a greater folder depth than one, allowing other smart contracts to access
and edit Grid Document state, and incorporating permissions. This section
explains how Grid Document may be improved in the future.

### Folder Depth

Grid Document currently supports a single layer of folders. More complex folder
organization may be implemented by augmenting the addressing formulas for files
or folders. The state address of a folder is currently calculated using a
pre-defined prefix and a hash of the folder’s name. More complex addressing
techniques may include allowing relative paths in file name hashes, hashing a
folder’s parent directories along with its unique name, or prefixing an addresses
namespace to separate files and additional content.  Adding these to the
addressing formulas defined earlier would allow more flexibility to store
additional folders, without rendering the predefined formulas useless.

#### Relative path in file names

One route to allowing more complex file organization in Grid Document state is
to allow relative paths within a file name. Files could include a slash
character to represent the successive levels of directories. Folders in state
would remain in a single layer. This would also use the same addressing formulas
defined earlier and does not add complexity to storing additional
folder contents.

#### Relative path in folder names

Support for multi-level folder schemes could be incorporated by enforcing a
format to indicate multiple folders in a path. Users are accustomed to folder
and file paths joined by a slash character, "/", which makes it simple for users
to understand within Grid Document.

The folder state object will be extended to include a list of folder names to
support folder depth greater than one. Grid Document would use the common
slash character, "/", to indicate nested folder references. The transaction to
create a folder could take in a nested folder path, separated by "/". If one of
the folders in the path does not exist, the transaction would be invalid. If all
files in the path exist, the folder will be created within the destination
folder. Furthermore, a file may also be saved within a nested folder. The
`folder` argument in the `CreateFileAction` payload will also take a path
separated by a slash character. If any of the folders in this path do not exist,
the transaction is invalid.

The full path of a folder in Grid Document state, including parent folders up to
DocumentRoot, may be used to calculate state addresses rather than just the
unique folder name. However, allowing more folders in state may also necessitate
increasing the number of characters to refer to the folder in state addresses
to avoid hash collisions. This may also necessitate more safe-guards to ensure
state size does not grow exponentionally.

#### Folder namespace prefixes

Additionally, additional folder layers may be addressed in Grid Document by
using the already existing folder address. This address can be further prefixed
using 2-hex-characters, similar to the construction of the first part. The “00”
prefix would be reserved for storing files. The formula for a file would be as
follows:

```
“621dee” + “07” + “01” + Sha512(folder_name)[10:] + “00” + Sha512(file_name)[48:]
```
Grid Document may allow folders to be addressed under other folders using the
following formula:

```
“621dee” + “07” + “01” + Sha512(folder_name)[10:] + “01” + Sha512(folder_name)[48:]
```

The remaining namespaces may be defined in the future, depending on the needs of
the smart contract or specific implementations.

### Access to Grid Document state

Sharing documents is useful alongside other Grid smart contracts. Other smart
contracts may read and/or write to Grid Document state by adding the namespace
to transaction inputs and/or outputs. Addresses from the inputs of a transaction
are able to be read while the addresses in the the outputs may be written to by
the transaction. This will be interesting in cases where users want to provide
more context or corroborating inter company communications. A simple example of
this would be a supplier uploading an image of the product in a purchase order
as it is shipped off.

### Permissions

Grid Document does not initially enforce permissions, but may be extended to
support both Grid Pike and Workflow. In both cases, Grid Document could validate
permissions to access, create, or delete a file or folder. An organization would
be indicated as the owner of a file or folder. The organization indicated as the
owner defines if and how agents, within and outside of the organization, may
interact with files and folders in state.

#### Incorporating Pike

Grid Document can validate permissions to create or delete a file or folder
using Grid Pike. An agent is assigned one or more Pike roles, defined by the
organization, which contain permissions to alter Grid state. Permissions are
enforced by the Grid Pike smart contract when executing a Grid Document
transaction. Files and folders will include an `owner_id` field, to indicate the
owner’s Grid Pike organization ID. The owning organization is then able to assign
roles for using Grid Document to agents within and outside of their
organization.

If an organization maintains multiple folders with unique permissions, an
additional field may be added to the folder state object. This field would
be an organization-unique “group_id”, used in permissions to define an agent’s
level of access to a folder. Permissions specific to these groups will be
post-fixed with the unique “group_id” field. For example, permissions for a
folder with the “group_id” field “01234” may include `can-alter-01234`,
`can-delete-01234` or `can-create-01234`.

State objects could be extended to support Grid Pike as follows:

```
message Folder {
  …
  string owner_id = 3;
  string group_id = 4; // optional
}

message File {
	…
	string owner_id = 3;
}
```

Transactions will validate that the submitting agent has been permitted to
execute the transaction. The transaction messages and validation requirements
will be extended as follows:

##### CreateFolderAction

To create a folder, an agent must be assigned the `document::can-create-folder`
permission by the owning-organization. If the agent does not have this permission,
the transaction is invalid. If the transaction includes a `group_id`, the agent
must have the `document::can-create-<group_id>` permission for the transaction
to be valid. The transaction payload will be extended as follows:

```
message CreateFolderAction {
  …
  string owner_id = 2;
  string group_id = 3; // optional
}
```

##### DeleteFolderAction

In order to delete a folder, an agent must have been assigned the
`document::can-delete-folder` permission by the owner organization. Otherwise,
the transaction is invalid. If the specified folder contains a `group_id`, the
agent must also have the `document::can-delete-<group_id>` permission for the
transaction to be valid. The transaction payload will remain the same.

##### CreateFileAction

To create a file within a folder, an agent must have the
`document::can-create-file` permission for the owner organization. If the
destination folder contains a `group_id`, the agent must also have the
`document::can-alter-<group_id>` permission. Otherwise, the transaction is
invalid.

##### DeleteFileAction

An agent must be assigned the `document::can-delete-file` permission by the
owner organization to delete a file. If the folder has a `group_id`, the agent
must also have a `document::can-alter-<group_id>` permission. If the agent
does not have the correct permissions, the transaction is invalid.

#### Workflow Permissions

Grid Workflow gives granular control over how agents interact with files and
folders and the different states of those objects. The main workflow consists
of sub-workflows, representing unique workflow states and defines how objects
may move through these states. To enforce workflow permissions, files and
folders will be extended to include workflow identifiers. Additionally,
transactions will be extended to include workflow arguments. Allowing Grid
Document to validate transactions with workflow permissions assigned to agents
by their organization.

To support workflow permissions at the folder and file level, both state objects
will have a `workflow_state` field, indicating the object’s position within the
subworkflow. The folder object will hold a workflow identifier, allowing Grid
Document access to the workflow’s state.

```
message Folder {
  …
  string workflow_state = 4;
  string workflow_id = 5;
}

message File {
  …
  string worfklow_state = 4;
}
```

Furthermore, transactions will be extended to allow these state objects to move
through workflow states. Workflow states allow for more complex permission
configurations using constraints, which may be supported by adding fields to the
transactions and/or state objects. Therefore, future validation requirements may
vary from the ones described below to include more robust rules around workflow
constraints. Grid Document transactions may appear as follows:

##### CreateFolderAction
The action to create a folder will include a `workflow_id` and `workflow_state`
field. These fields must refer to an existing workflow and workflow state for the
transaction to be valid.  Additionally, the agent submitting the transaction must
have the workflow permission `document::can-create-folder` within the specified
workflow state.

```
message CreateFolderAction {
  …
  string workflow_id = 4;
  string workflow_state = 5;
}
```

##### DeleteFolderAction
The transaction payload to delete a folder does not need to be extended to
support workflow permissions. An agent attempting to delete a folder must
have the `document::can-delete-folder` permission for the current workflow
state of the folder. If the agent does not have this permission within the
folder’s workflow state, the transaction is invalid.

##### CreateFileAction
The transaction to create a file will be extended to include a `workflow_state`.
This allows Grid Document to verify the submitting agent has the
`document::can-create-file` within the indicated `workflow_state`. Furthermore,
Grid Document will validate that the submitting agent has the
`document::can-access-folder` permission for the folder in its current workflow
state. If the agent does not have either of these permissions, the transaction
is invalid. The transaction payload may appear as follows:

```
message CreateFileAction {
  …
  string workflow_state = 4;
}
```

##### DeleteFileAction
The transaction payload to delete a file will also remain unchanged to support
workflow permissions. An agent attempting to delete a file must have the
`document::can-delete-file` permission within the file’s current workflow state.
Additionally, Grid Document will validate that the agent has the
`document::can-access-folder` permission for the parent folder’s current workflow
state. If the submitting agent does not have either of these permissions, the
transaction is invalid.

## Drawbacks
[drawbacks]: #drawbacks

This change will increase the size of state for grid instances. There is not a
way around this as the files have to be saved somewhere. This necessitates the
ability to groom state, i.e., deleting files and folders. Based on Grid’s
storage backend, this may cause issues with large amounts of historical
data being persisted. Grid Document allows for deleting objects from state and
state pruning techniques are already employed to maintain state size.

## Rationale and alternatives
[alternatives]: #alternatives

### Rationale

* Light-weight implementation

* Very familiar and simple use-case to ease users in to Grid

### Alternatives

* Users may use e-mail or online document sharing sites. This does not
  necessarily provide the same amount of security as Grid Document.

## Prior art
[prior-art]: #prior-art

Interplanetary File System + good key management does largely the same thing, in
largely the same way. It uses the hash of a file as a content ID and the file
gets split up into a bunch of smaller cacheable pieces that get stored on other
nodes. This caching mechanism means files can be very persistent, but by default
they are globally accessible and unencrypted.

DropBox has DocSend, which is advertised as a way to “Securely send critical
documents and get real-time analytics”. The biggest downside is that it is
closed source, paid, and not easily automatable.

## Unresolved questions
[unresolved]: #unresolved-questions

* File count per directory, directory count. Should those be user settings or
  immutable system defaults?

* What should Grid Document’s default be for file count per directory and
  directory count?

* Should file count per directory and directory count be user settings in Grid
  Document? A separate transaction to create a folder would allow users to
  choose a maximum file count.

* Should files be allowed to be created without providing a destination folder?

* Should Grid Document provide a default file location?
