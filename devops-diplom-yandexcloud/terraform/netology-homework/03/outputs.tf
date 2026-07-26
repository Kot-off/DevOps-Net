output "vms_list" {
  value = concat(
    [for v in yandex_compute_instance.web : {name=v.name, id=v.id, fqdn=v.fqdn}],
    [for v in yandex_compute_instance.db : {name=v.name, id=v.id, fqdn=v.fqdn}],
    [{name=yandex_compute_instance.storage.name, id=yandex_compute_instance.storage.id, fqdn=yandex_compute_instance.storage.fqdn}]
  )
}