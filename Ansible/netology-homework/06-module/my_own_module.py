#!/usr/bin/python

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.module_utils.basic import AnsibleModule
import os

DOCUMENTATION = r'''
---
module: my_own_module
short_description: Модуль создает файл с заданным содержимым
description: Это тестовый модуль для создания текстового файла на удаленном хосте.
options:
    path:
        description: Путь к создаваемому файлу.
        required: true
        type: str
    content:
        description: Содержимое файла.
        required: true
        type: str
author:
    - Your Name (@yourGitHubHandle)
'''

def run_module():
    # Описываем входящие параметры
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=True)
    )

    result = dict(
        changed=False,
        path='',
        message=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    path = module.params['path']
    content = module.params['content']

    # Проверка текущего состояния для обеспечения идемпотентности
    if os.path.exists(path):
        with open(path, 'r') as f:
            if f.read() == content:
                # Если файл есть и контент совпадает - ничего не меняем
                result['path'] = path
                result['message'] = 'File already exists with same content'
                module.exit_json(**result)

    if module.check_mode:
        module.exit_json(changed=True)

    # Выполнение действия
    try:
        with open(path, 'w') as f:
            f.write(content)
        result['changed'] = True
        result['path'] = path
        result['message'] = 'File created successfully'
    except Exception as e:
        module.fail_json(msg=f"Can't create file: {str(e)}", **result)

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()