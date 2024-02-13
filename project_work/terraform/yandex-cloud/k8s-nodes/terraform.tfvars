#=========== node_groups ==============
node_groups = {
  node-group-a = {
    platform_id    = "standard-v1",
    name           = "worker-a-{instance.short_id}",
    cores          = 2,
    memory         = 2,
    boot_disk_type = "network-hdd",
    boot_disk_size = 32,
    zone           = "ru-central1-a",
    auto_scale = {
      min     = 1,
      max     = 3,
      initial = 1
    }
  }
  node-group-b = {
    platform_id    = "standard-v1",
    name           = "worker-b-{instance.short_id}",
    cores          = 2,
    memory         = 2,
    boot_disk_type = "network-hdd",
    boot_disk_size = 32,
    zone           = "ru-central1-b",
    fixed_scale = {
      size     = 1
    }
  }
  node-group-d = {
    # В зоне d нет standard-v1
    platform_id    = "standard-v2",
    name           = "worker-d-{instance.short_id}",
    cores          = 2,
    memory         = 2,
    boot_disk_type = "network-hdd",
    boot_disk_size = 32,
    zone           = "ru-central1-d",
    fixed_scale = {
      size     = 1
    }
  }
}
