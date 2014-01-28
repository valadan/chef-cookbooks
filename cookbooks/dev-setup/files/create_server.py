cd('/')
cmo.createServer('applications')

cd('/Servers/applications')
cmo.setListenPort(7710)
cmo.setTunnelingEnabled(true)

activate()