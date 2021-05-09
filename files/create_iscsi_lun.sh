#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Create a iSCSI LUN using a file back-store
# ------------------------------------------------------------------------------

tgt_file=/tmp/disk1.img
tgt_name="iqn.2021-05.au.id.yaocm:filedisk1"
acl_name="iqn.2021-05.au.id.yaocm:client1"

# -------------------- Create File I/O Back-store

backstores=$(targetcli ls backstores/fileio)
if [[ ! "${backstores}" =~ ${tgt_file} ]]
then
    targetcli /backstores/fileio create file1 "${tgt_file}" 200M write_back=false
    printf "Added %s as File I/O Back-store\n" "${tgt_file}"
else
    printf "%s already exists as File I/O Back-store\n" "${tgt_file}"
fi
backstores=$(targetcli ls backstores/fileio)
printf "%s\n" "${backstores}"

# -------------------- Create iSCSI target portal group (TPG)

tpgs=$(targetcli ls iscsi)
if [[ ! "${tpgs}" =~ ${tgt_name} ]]
then
    targetcli /iscsi create "${tgt_name}"
    printf "Added iSCSI target %s\n" "${tgt_name}"
else
    printf "iSCSI target %s already exists\n" "${tgt_name}"
fi
tpgs=$(targetcli ls iscsi)
printf "%s\n" "${tpgs}"

# -------------------- Create iSCSI LUN

luns=$(targetcli ls iscsi/"${tgt_name}"/tpg1/luns)
if [[ "${luns}" =~ \[LUNs:\ 0\] ]]
then
    targetcli /iscsi/"${tgt_name}"/tpg1/luns create /backstores/fileio/file1
    printf "Added LUN\n"
else
    printf "LUN already defined\n"
fi
luns=$(targetcli ls iscsi/"${tgt_name}"/tpg1/luns)
printf "%s\n" "${luns}"

# -------------------- Create Access Control List (ACL)

acls=$(targetcli ls iscsi/"${tgt_name}"/tpg1/acls)
if [[ ! "${acls}" =~ ${acl_name} ]]
then
    targetcli iscsi/"${tgt_name}"/tpg1/acls/ create "${acl_name}"
    printf "Added ACL\n"
else
    printf "ACL already exists\n"
fi
acls=$(targetcli ls iscsi/"${tgt_name}"/tpg1/acls)
printf "%s\n" "${acls}"

# -------------------- Create simple user

targetcli /iscsi/"${tgt_name}"/tpg1/acls/"${acl_name}"/ set auth userid=user1
targetcli /iscsi/"${tgt_name}"/tpg1/acls/"${acl_name}"/ set auth password=password

