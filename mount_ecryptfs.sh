#!/bin/bash
if (($# < 2)); then
	echo "usage: <ecryptfs folder> <mount point>"
	exit 0
fi

if [ -e "$1" ]; then
	if [ -d "$1" ]; then
		ROOT="$1"
	else
		echo "The path to ecryptfs folder is not a directory. Please check for the correct path."
		exit 2
	fi
else
	echo "The ecryptfs folder specified doesn't exist. Please check for the correct path."
	exit 1
fi
TARGET="$2"

echo "You are about to mount \"$ROOT\" into \"$TARGET\""
echo "Please don't type anything into terminal unless prompted until end of process."
echo ""
echo "Enter your password:"

sudo mkdir -p "$TARGET"
cd "$ROOT"

echo "Enter ecryptfs owner's user password:"
PASS=$(ecryptfs-unwrap-passphrase .ecryptfs/wrapped-passphrase | sed s/Passphrase:\ //)
SIG1=$(head -n1 .ecryptfs/Private.sig)
SIG2=$(tail -n1 .ecryptfs/Private.sig)

echo "Passphrase:"
echo $PASS
echo "Signatures:"
echo $SIG1
echo $SIG2

echo "Clearing user keyring..."
sudo keyctl clear @u
sudo keyctl list @u

echo ":::PLEASE DO NOT TYPE ANYTHING:::"
echo $PASS | sudo ecryptfs-add-passphrase --fnek

echo "Checking signatures..."
sudo keyctl list @u

echo "Mounting $ROOT on $TARGET..."
sudo mount -t ecryptfs -o key=passphrase,ecryptfs_cipher=aes,ecryptfs_key_bytes=16,ecryptfs_passthrough=no,ecryptfs_enable_filename_crypto=yes,ecryptfs_sig=$SIG1,ecryptfs_fnek_sig=$SIG2,passwd=$(echo $PASS) .Private "$TARGET"

ls "$TARGET"

