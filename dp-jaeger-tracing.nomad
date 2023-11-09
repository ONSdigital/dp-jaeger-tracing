job "dp-jaeger-tracing" {
  datacenters = ["eu-west-2"]
  region      = "eu"
  type        = "service"

  group "management" {
    count = "{{MANAGEMENT_TASK_COUNT}}"

    constraint {
      attribute = "${node.class}"
      value     = "management"
    }

    restart {
      attempts = 3
      delay    = "15s"
      interval = "1m"
      mode     = "delay"
    }

      network {
      port "grpc" {
        to = 4317
      }
      port "ui" {
        to = 16686
      }
    }

    service {
      name = "dp-jaeger-tracing"
      port = "grpc"
      tags = ["management","jaeger"]

      check {
        type     = "http"
        port     = "health"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "dp-jaeger-tracing" {
      driver = "docker"

      config {
        image = "{{ECR_URL}}:concourse-{{REVISION}}"
        ports = ["grpc", "ui"]
      }

      resources {
        cpu    = "{{MANAGEMENT_RESOURCE_CPU}}"
        memory = "{{MANAGEMENT_RESOURCE_MEM}}"
      }

      template {
        data = <<EOH
        # Configs based on environment (e.g. export BIND_ADDR=":{{ env "NOMAD_PORT_http" }}")
        # or static (e.g. export BIND_ADDR=":8080")

        # Secret configs read from vault
        {{ with (secret (print "secret/" (env "NOMAD_TASK_NAME"))) }}
        {{ range $key, $value := .Data }}
        export {{ $key }}="{{ $value }}"
        {{ end }}
        {{ end }}
        EOH

        destination = "secrets/app.env"
        env         = true
        splay       = "1m"
        change_mode = "restart"
      }

      vault {
        policies = ["dp-jaeger-tracing"]
      }
    }
  }

  group "web" {
    count = "{{WEB_TASK_COUNT}}"

    constraint {
      attribute = "${node.class}"
      value     = "web"
    }

    restart {
      attempts = 3
      delay    = "15s"
      interval = "1m"
      mode     = "delay"
    }

    network {
      port "grpc" {
        to = 4317
      }
      port "ui" {
        to = 16686
      }
    }

    service {
      name = "dp-jaeger-tracing"
      port = "grpc"
      tags = ["web","jaeger"]

      check {
        type     = "http"
        port     = "health"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "dp-jaeger-tracing" {
      driver = "docker"

      config {
        image = "{{ECR_URL}}:concourse-{{REVISION}}"
        ports = ["grpc","ui"]
      }

      resources {
        cpu    = "{{WEB_RESOURCE_CPU}}"
        memory = "{{WEB_RESOURCE_MEM}}"
      }

      template {
        data = <<EOH
        # Configs based on environment (e.g. export BIND_ADDR=":{{ env "NOMAD_PORT_http" }}")
        # or static (e.g. export BIND_ADDR=":8080")

        # Secret configs read from vault
        {{ with (secret (print "secret/" (env "NOMAD_TASK_NAME"))) }}
        {{ range $key, $value := .Data }}
        export {{ $key }}="{{ $value }}"
        {{ end }}
        {{ end }}
        EOH

        destination = "secrets/app.env"
        env         = true
        splay       = "1m"
        change_mode = "restart"
      }

      vault {
        policies = ["dp-jaeger-tracing"]
      }
    }
  }

  group "publishing" {
    count = "{{PUBLISHING_TASK_COUNT}}"

    constraint {
      attribute = "${node.class}"
      value     = "publishing"
    }

    restart {
      attempts = 3
      delay    = "15s"
      interval = "1m"
      mode     = "delay"
    }

    network {
      port "grpc" {
        to = 4317
      }
      port "ui" {
        to = 16686
      }
    }

    service {
      name = "dp-jaeger-tracing"
      port = "grpc"
      tags = ["publishing","otel-collector"]

      check {
        type     = "http"
        port     = "health"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "dp-jaeger-tracing" {
      driver = "docker"

      config {
        image = "{{ECR_URL}}:concourse-{{REVISION}}"
        ports = ["grpc","ui"]
      }

      resources {
        cpu    = "{{PUBLISHING_RESOURCE_CPU}}"
        memory = "{{PUBLISHING_RESOURCE_MEM}}"
      }

      template {
        data = <<EOH
        # Configs based on environment (e.g. export BIND_ADDR=":{{ env "NOMAD_PORT_http" }}")
        # or static (e.g. export BIND_ADDR=":8080")

        # Secret configs read from vault
        {{ with (secret (print "secret/" (env "NOMAD_TASK_NAME"))) }}
        {{ range $key, $value := .Data }}
        export {{ $key }}="{{ $value }}"
        {{ end }}
        {{ end }}
        EOH

        destination = "secrets/app.env"
        env         = true
        splay       = "1m"
        change_mode = "restart"
      }

      vault {
        policies = ["dp-jaeger-tracing"]
      }
    }
  }
}
