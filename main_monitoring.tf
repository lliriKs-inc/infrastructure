resource "yandex_monitoring_dashboard" "vet_dashboard" {
  name        = "vet-clinic-dashboard-final-v3"
  title       = "Vet Clinic Monitor"
  description = "Monitoring for ALB and VM Group"
  folder_id   = var.folder_id

  # Виджет 1: RPS (Правильное имя из скриншота)
  widgets {
    chart {
      chart_id = "chart_rps"
      title    = "Balancer RPS"
      
      queries {
        target {
          query = "series_sum(load_balancer.requests_count_per_second{service=\"application-load-balancer\", load_balancer=\"${yandex_alb_load_balancer.alb.id}\"})"
        }
      }
    }
    
    position {
      x = 0
      y = 0
      w = 20
      h = 10
    }
  }

  # Виджет 2: Active Connections (Исправлено имя: добавлено .scaling.)
  widgets {
    chart {
      chart_id = "chart_connections"
      title    = "Active Connections"
      
      queries {
        target {
          # ВОТ ТУТ БЫЛА ОШИБКА, теперь правильно:
          query = "series_sum(load_balancer.scaling.active_connections{service=\"application-load-balancer\", load_balancer=\"${yandex_alb_load_balancer.alb.id}\"})"
        }
      }
    }
    
    position {
      x = 20
      y = 0
      w = 20
      h = 10
    }
  }

  # Виджет 3: Backend Health (Это отдельная метрика, она обычно работает без префикса load_balancer, но проверим)
  widgets {
    chart {
      chart_id = "http_received"
      title    = "HTTP_received_bytes_per_second"
      
      queries {
        target {
          # Здесь обычно работает так (по backend_group, а не load_balancer):
          query = "series_avg(load_balancer.scaling.http_received_bytes_per_second{service=\"application-load-balancer\"})"
        }
      }
    }
    
    position {
      x = 0
      y = 10
      w = 20
      h = 10
    }
  }
}
