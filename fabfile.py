from fabric.api import task, run, cd, env

env.hosts = '133.50.173.85'
env.port = 22
env.user = 'root'
env.key_filename = '~/.ssh/hokudai'

def deploy():
    with cd('/var/app/a2ms-api'):
        run('bash build.sh')
