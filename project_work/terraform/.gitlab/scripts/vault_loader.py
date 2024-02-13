#!/usr/bin/env python3

import base64
import json
import optparse
import os
import sys
from urllib import request
from getpass import getpass

optparser = optparse.OptionParser()
optparser.add_option(
    '--vault_addr',
    '-a',
    dest='vault_addr',
    default=None,
    help='Aдреc Hashicorp Vault (обязательно)',
)
optparser.add_option(
    '--role',
    '-r',
    dest='role',
    default=None,
    help='Роль Vault с правами которой бует запрошено значение (обязательно)',
)
optparser.add_option(
    '--token',
    '-t',
    dest='vault_token',
    default=None,
    help='Токен Hashicorp Vault',
)
optparser.add_option(
    '--file_b64',
    '-b',
    dest='file_base64',
    action='append',
    default=[],
    help="Путь до объекта который нужно раскодировать из base64 и записать в файл \
        Формат:\"адрес/в/vault:поле_в_vault\"",
)
optparser.add_option(
    '--file',
    '-f',
    dest='file',
    action='append',
    default=[],
    help="Путь до объекта который нужно записать в файл\
            Формат:\"адрес/в/vault:поле_в_vault:путь/для/записи\"",
)
optparser.add_option(
    '--value',
    '-v',
    dest='value',
    default=None,
    help="Путь до объекта который будет выведен в консоль, передать можно только один объект\
        Формат:\"адрес/в/vault:поле_в_vault\"",
)
optparser.add_option(
    '--ldap_user',
    '-u',
    dest='ldap_user',
    default=None,
    help='Имя LDAP пользователя. При указании токена будет проигнорировано.',
)
optparser.add_option(
    '--ldap_pass',
    '-p',
    dest='ldap_pass',
    default=None,
    help='Пароль ldap, если не указан будет запрошен в консоли,'\
        "Формат:\"адрес/в/vault:поле_в_vault\"",
)

(options, args) = optparser.parse_args(sys.argv)

VAULT_ADDR = options.vault_addr


def get_vault_val(val, field):
    req = request.Request(f'{VAULT_ADDR}/v1/{val}')
    req.add_header('X-Vault-Token', VAULT_TOKEN)
    req.add_header('accept', '*/*')
    request_data = json.loads(
        request.urlopen(req).read(),
    )['data']['data'][field]
    return request_data

def get_token_by_ldap(ldap_user, ldap_pass = ''):
    if not ldap_pass:
        ldap_pass = getpass('LDAP Password: ')
    request_data = f'{{"password": "{ldap_pass}"}}'
    req = request.Request(
            f'{VAULT_ADDR}/v1/auth/ldap/login/{ldap_user}',
            data=str.encode(request_data),
    )
    req.add_header('accept', '*/*')
    req.add_header('Content-Type', 'application/json')
    responce = request.urlopen(req).read()
    vault_token = json.loads(responce)['auth']['client_token']
    return vault_token

def get_token_by_jwt(role, jwt=None):
    if not jwt:
        jwt = os.getenv('CI_JOB_JWT')
    request_data = f'{{"jwt":"{jwt}","role":"{role}"}}'
    jwt=os.getenv('CI_JOB_JWT'),
    req = request.Request(
            f'{VAULT_ADDR}/v1/auth/jwt/login',
            data=str.encode(request_data),
    )
    req.add_header('accept', '*/*')
    req.add_header('Content-Type', 'application/json')
    responce = request.urlopen(req).read()
    vault_token = json.loads(responce)['auth']['client_token']
    return vault_token

if __name__ == '__main__':
    if options.vault_token:
        VAULT_TOKEN = options.vault_token
    elif options.ldap_user:
        VAULT_TOKEN = get_token_by_ldap(options.ldap_user, options.ldap_pass)
    else:
        VAULT_TOKEN = get_token_by_jwt(options.role)

    for item in options.file_base64:
        val = item.split(':')
        request_data = get_vault_val(val[0], val[1])
        with open(val[2], 'wb') as f:
            f.write(base64.b64decode(request_data))

    for item in options.file:
        val = item.split(':')
        request_data = get_vault_val(val[0], val[1])
        with open(val[2], 'w') as f:
            f.write(request_data)

    if options.value:
        val = options.value.split(':')
        request_data = get_vault_val(val[0], val[1])
        # Выводим в консоль для записи в переменную окружения
        # или передачи в качестве параметра
        print(request_data)
