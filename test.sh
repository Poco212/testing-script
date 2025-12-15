EFI=/dev/nvme0n1p1
EFI_UUID=$(blkid -s UUID -o value $(findmnt -n -o SOURCE "$EFI"))

echo "$EFI_UUID" > test
