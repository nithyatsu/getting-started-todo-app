extension radius

param environment string
param image string = ''

@secure()
param password string

resource app 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'todo-app'
  properties: {
    environment: environment
  }
}

resource mysqlDb 'Radius.Data/mySqlDatabases@2025-08-01-preview' = {
  name: 'todo-app-mysql'
  properties: {
    environment: environment
    application: app.id
    database: 'todos'
    version: '8.4'
    username: 'radiusadmin'
    password: password
  }
}

resource todoImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'todo-app-image'
  properties: {
    environment: environment
    application: app.id
    build: {
      source: 'git::https://github.com/nithyatsu/getting-started-todo-app.git?ref=eda85f3ff7bf4480db45e055406e321d5896e2b5'
      platforms: ['linux/amd64']
    }
  }
}

resource todoContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'todo-app'
  properties: {
    environment: environment
    application: app.id
    containers: {
      todo: {
        image: todoImage.properties.imageReference
        ports: {
          web: {
            containerPort: 3000
          }
        }
        env: {
          MYSQL_HOST: {
            value: mysqlDb.properties.host
          }
          MYSQL_USER: {
            value: 'radiusadmin'
          }
          MYSQL_PASSWORD: {
            value: password
          }
          MYSQL_DB: {
            value: 'todos'
          }
        }
      }
    }
  }
}
