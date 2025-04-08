import 'dart:convert';
import 'package:http/http.dart' as http;

class PopulateDatabase {
  static final client = http.Client();

  static Future<String> populateAsync() async {
    try {
      // Datos de ejemplo para cada tabla
      var tasks = [
        {
          "name": "Distribuir alimentos",
          "description": "Distribuir alimentos a las familias afectadas.",
          "location_id": 1,
          "priority": "Alta",
          "status": "Pendiente",
          "admin_id": 1
        },
        {
          "name": "Reparar techos",
          "description": "Reparar techos dañados por la tormenta.",
          "location_id": 2,
          "priority": "Crítica",
          "status": "Asignada",
          "admin_id": 1
        },
        {
          "name": "Organizar refugio",
          "description": "Preparar un refugio temporal para los afectados.",
          "location_id": 3,
          "priority": "Media",
          "status": "En progreso",
          "admin_id": 1
        },
        {
          "name": "Distribuir ropa",
          "description": "Distribuir ropa donada a los afectados.",
          "location_id": 4,
          "priority": "Baja",
          "status": "Completada",
          "admin_id": 1
        }
      ];

      var volunteers = [
        {
          "name": "Juan Pérez",
          "surname": "Pérez",
          "email": "juan.perez@example.com",
          "password": "password123",
          "prefix": 34,
          "phone_number": 123456789,
          "address": "Calle Falsa 123",
          "identification": "12345678A",
          "location_id": 1
        },
        {
          "name": "María López",
          "surname": "López",
          "email": "maria.lopez@example.com",
          "password": "password123",
          "prefix": 34,
          "phone_number": 987654321,
          "address": "Avenida Siempre Viva 742",
          "identification": "87654321B",
          "location_id": 2
        },
        {
          "name": "Carlos García",
          "surname": "García",
          "email": "carlos.garcia@example.com",
          "password": "password123",
          "prefix": 34,
          "phone_number": 112233445,
          "address": "Plaza Mayor 1",
          "identification": "11223344C",
          "location_id": 3
        },
        {
          "name": "Ana Martínez",
          "surname": "Martínez",
          "email": "ana.martinez@example.com",
          "password": "password123",
          "prefix": 34,
          "phone_number": 556677889,
          "address": "Calle Luna 45",
          "identification": "55667788D",
          "location_id": 4
        }
      ];

      var skills = [
        {"name": "Carpentry", "level": "Intermediate", "admin_id": 1},
        {"name": "First Aid", "level": "Expert", "admin_id": 1},
        {"name": "Cooking", "level": "Beginner", "admin_id": 1},
        {"name": "Driving", "level": "Expert", "admin_id": 1}
      ];

      var taskSkills = [
        {"task_id": 1, "skill_id": 1},
        {"task_id": 2, "skill_id": 3},
        {"task_id": 3, "skill_id": 2},
        {"task_id": 4, "skill_id": 4}
      ];

      var volunteerTasks = [
        {"volunteer_id": 1, "task_id": 1},
        {"volunteer_id": 2, "task_id": 2},
        {"volunteer_id": 3, "task_id": 3},
        {"volunteer_id": 4, "task_id": 4}
      ];

      var volunteerSkills = [
        {"volunteer_id": 1, "skill_id": 1},
        {"volunteer_id": 2, "skill_id": 3},
        {"volunteer_id": 3, "skill_id": 2},
        {"volunteer_id": 4, "skill_id": 4}
      ];

      var affectedZones = [
        {
          "name": "Zone A",
          "description": "Area affected by flooding.",
          "hazard_level": "High",
          "admin_id": 1
        },
        {
          "name": "Zone B",
          "description": "Area affected by landslides.",
          "hazard_level": "Medium",
          "admin_id": 1
        },
        {
          "name": "Zone C",
          "description": "Area affected by earthquakes.",
          "hazard_level": "Critical",
          "admin_id": 1
        },
        {
          "name": "Zone D",
          "description": "Area affected by wildfires.",
          "hazard_level": "High",
          "admin_id": 1
        }
      ];

      var affectedZoneLocations = [
        {"affected_zone_id": 1, "location_id": 1},
        {"affected_zone_id": 2, "location_id": 2},
        {"affected_zone_id": 3, "location_id": 3},
        {"affected_zone_id": 4, "location_id": 4}
      ];

      // Poblar las tablas
      await _populateTable("tasks", tasks);
      await _populateTable("volunteers", volunteers);
      await _populateTable("skills", skills);
      await _populateTable("task_skills", taskSkills);
      await _populateTable("volunteer_tasks", volunteerTasks);
      await _populateTable("volunteer_skills", volunteerSkills);
      await _populateTable("affected_zones", affectedZones);
      await _populateTable("affected_zone_locations", affectedZoneLocations);

      return "Base de datos completada con éxito.";
    } catch (e) {
      return "Error general: $e";
    }
  }

  static Future<void> _populateTable(String endpoint, List<Map<String, dynamic>> data) async {
    for (var item in data) {
      try {
        final response = await client.post(
          Uri.parse("http://localhost:5170/api/v1/$endpoint"),
          headers: {"Content-Type": "application/json"},
          body: json.encode(item),
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception("Error al insertar en $endpoint: ${response.body}");
        }
      } catch (e) {
        print("Error al insertar en $endpoint: $e\nDatos: $item");
      }
    }
  }

  static Future<String> clearDatabase() async {
  try {
    // Define el orden de eliminación respetando las restricciones de claves foráneas
    final tables = [
      "task",
      "volunteer_task",
      "task_skill",
      "volunteer_time",
      "task_time",
      "need_task",
      "need_skill",
      "need_need_type",
      "affected_zone_location",
      "place_affected_zone",
      "task_donation",
      "volunteer_place",
      "route_location",
      "physical_donation",
      "monetary_donation",
      "volunteer_skill", // Mueve esta tabla después de las tablas principales
      "volunteer",
      "task",
      "need",
      "need_type",
      "skill",
      "route",
      "place",
      "affected_zone",
      "location",
      "victim"
    ];

    for (var table in tables) {
      final response = await client.delete(
        Uri.parse("http://localhost:5170/api/v1/database/clear/$table"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode != 200) {
        throw Exception("Error al vaciar la tabla $table: ${response.body}");
      }
    }

    return "Base de datos vaciada con éxito.";
  } catch (e) {
    return "Error al vaciar la base de datos: $e";
  }
}
}