#This is an example of using Bcache with a ramdisk and BTRFS, i decided to post this cron i had before switching over to ZFS, I hope it helps.
#FYI the biggest problem when doing this setup with BTRFS is that you lose the ability to post any time you do an unclean shutdown with the ram cache.
#This can be avoided by detaching the ram device first using a simple script upon shutdown. 

#Make Bcache Device On Boot
#       @reboot /usr/sbin/make-bcache --cset-uuid c0000000-0000-0000-0000-000000000000 --block 4k --bucket 2M -C /dev/ram0 --wipe-bcache
#	@reboot /usr/sbin/make-bcache --cset-uuid c1111111-1111-1111-1111-111111111111 --block 4k --bucket 2M -C /dev/ram1 --wipe-bcache
#	@reboot /usr/sbin/make-bcache --cset-uuid c2222222-2222-2222-2222-222222222222 --block 4k --bucket 2M -C /dev/ram2 --wipe-bcache
#Register Bcache Device 2 Seconds After Making The Ram Cache Device
#       @reboot /bin/sleep 2 && /bin/echo /dev/ram0 > /sys/fs/bcache/register_quiet
#       @reboot /bin/sleep 2 && /bin/echo /dev/ram1 > /sys/fs/bcache/register_quiet
#       @reboot /bin/sleep 2 && /bin/echo /dev/ram2 > /sys/fs/bcache/register_quiet
#Confirm Ramblock Device Attachment To Bcache
#       @reboot /bin/sleep 4 && /bin/echo c0000000-0000-0000-0000-000000000000 > /sys/block/nvme0n1/nvme0n1p1/bcache/attach
#       @reboot /bin/sleep 4 && /bin/echo c1111111-1111-1111-1111-111111111111 > /sys/block/nvme1n1/nvme1n1p1/bcache/attach
#       @reboot /bin/sleep 4 && /bin/echo c2222222-2222-2222-2222-222222222222 > /sys/block/nvme2n1/nvme2n1p1/bcache/attach
#Confirm Read Only Cacheing
#       @reboot /bin/sleep 6 && /bin/echo writearound > /sys/block/nvme0n1/nvme0n1p1/bcache/cache_mode
#       @reboot /bin/sleep 6 && /bin/echo writearound > /sys/block/nvme1n1/nvme1n1p1/bcache/cache_mode
#       @reboot /bin/sleep 6 && /bin/echo writearound > /sys/block/nvme2n1/nvme2n1p1/bcache/cache_mode
#Disable Writeback Running As A Safety
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme0n1/nvme0n1p1/bcache/writeback_running
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme1n1/nvme1n1p1/bcache/writeback_running
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme2n1/nvme2n1p1/bcache/writeback_running
#Increase Sequential Cutoff
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme0n1/nvme0n1p1/bcache/sequential_cutoff
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme1n1/nvme1n1p1/bcache/sequential_cutoff
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme2n1/nvme2n1p1/bcache/sequential_cutoff
#Disable Any latency Throtteling
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme0n1/nvme0n1p1/bcache/cache/cache0/set/congested_read_threshold_us
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme1n1/nvme1n1p1/bcache/cache/cache0/set/congested_read_threshold_us
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme2n1/nvme2n1p1/bcache/cache/cache0/set/congested_read_threshold_us
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme0n1/nvme0n1p1/bcache/cache/cache0/set/congested_write_threshold_us
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme1n1/nvme1n1p1/bcache/cache/cache0/set/congested_write_threshold_us
#       @reboot /bin/sleep 6 && /bin/echo 0 > /sys/block/nvme2n1/nvme2n1p1/bcache/cache/cache0/set/congested_write_threshold_us
#Disable Trim Optimizations For Btrfs, shows Bcache0 because BTRFS FS is on top of it (1 actually disables trim, dont ask me!)
#       @reboot /bin/sleep 4 && /bin/echo 1 > /sys/block/nvme0n1/nvme0n1p1/queue/rotational
#       @reboot /bin/sleep 4 && /bin/echo 1 > /sys/block/nvme1n1/nvme1n1p1/queue/rotational
#       @reboot /bin/sleep 4 && /bin/echo 1 > /sys/block/nvme2n1/nvme2n1p2/queue/rotational
#       @reboot /bin/sleep 4 && /bin/echo 1 > /sys/block/bcache0/queue/rotational
#       @reboot /bin/sleep 4 && /bin/echo 1 > /sys/block/bcache1/queue/rotational
#       @reboot /bin/sleep 4 && /bin/echo 1 > /sys/block/bcache2/queue/rotational
#Make sure bcache reflects read max sectors kb, most people dont do this but its a good idea.
#       @reboot /bin/sleep 5 && cat /sys/block/nvme0n1/nvme0n1p1/queue/max_sectors_kb > /sys/block/bcache0/queue/max_sectors_kb
#       @reboot /bin/sleep 5 && cat /sys/block/nvme1n1/nvme1n1p1/queue/max_sectors_kb > /sys/block/bcache1/queue/max_sectors_kb
#       @reboot /bin/sleep 5 && cat /sys/block/nvme2n1/nvme2n1p1/queue/max_sectors_kb > /sys/block/bcache2/queue/max_sectors_kb
#Make sure same as above but for read ahead KB
#	@reboot /bin/sleep 5 && cat /sys/block/nvme0n1/nvme0n1p1/queue/read_ahead_kb > /sys/block/bcache0/queue/read_ahead_kb
#	@reboot /bin/sleep 5 && cat /sys/block/nvme1n1/nvme1n1p1/queue/read_ahead_kb > /sys/block/bcache1/queue/read_ahead_kb
#	@reboot /bin/sleep 5 && cat /sys/block/nvme2n1/nvme2n1p1/queue/read_ahead_kb > /sys/block/bcache2/queue/read_ahead_kb
#Force 0% Writeback for safety
#       @reboot /bin/sleep 5 && /bin/echo 0 > /sys/block/bcache0/bcache/writeback_percent
#       @reboot /bin/sleep 5 && /bin/echo 0 > /sys/block/bcache1/bcache/writeback_percent
#       @reboot /bin/sleep 5 && /bin/echo 0 > /sys/block/bcache2/bcache/writeback_percent
#       @reboot /bin/sleep 5 && /bin/echo 0 > /sys/block/nvme0n1/nvme0n1p1/bcache/writeback_percent
#       @reboot /bin/sleep 5 && /bin/echo 0 > /sys/block/nvme1n1/nvme1n1p1/bcache/writeback_percent
#       @reboot /bin/sleep 5 && /bin/echo 0 > /sys/block/nvme2n1/nvme2n1p1/bcache/writeback_percent
