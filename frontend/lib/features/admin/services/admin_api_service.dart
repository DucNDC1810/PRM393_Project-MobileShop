import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_mobileshop/features/admin/models/admin_dashboard_stats.dart';
import 'package:project_mobileshop/features/admin/models/admin_product.dart';
import 'package:project_mobileshop/features/admin/models/admin_order.dart';
import 'package:project_mobileshop/features/admin/models/admin_conversation.dart';
import 'package:project_mobileshop/features/admin/models/admin_message.dart';

class AdminApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Use localhost or remote API

  // --- Dashboard ---
  Future<AdminDashboardStats> getDashboardStats() async {
    final response = await http.get(Uri.parse('\$baseUrl/admin/dashboard'));
    if (response.statusCode == 200) {
      return AdminDashboardStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  // --- Products ---
  Future<List<AdminProduct>> getProducts() async {
    final response = await http.get(Uri.parse('\$baseUrl/products'));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<AdminProduct>.from(l.map((model) => AdminProduct.fromJson(model)));
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<AdminProduct> createProduct(AdminProduct product) async {
    final response = await http.post(
      Uri.parse('\$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 201) {
      return AdminProduct.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create product');
    }
  }

  Future<AdminProduct> updateProduct(AdminProduct product) async {
    final response = await http.put(
      Uri.parse('\$baseUrl/products/\${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return AdminProduct.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('\$baseUrl/products/\$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  // --- Orders ---
  Future<List<AdminOrder>> getOrders() async {
    final response = await http.get(Uri.parse('\$baseUrl/orders'));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<AdminOrder>.from(l.map((model) => AdminOrder.fromJson(model)));
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    final response = await http.put(
      Uri.parse('\$baseUrl/orders/\$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }

  // --- Chat ---
  Future<List<AdminConversation>> getConversations() async {
    final response = await http.get(Uri.parse('\$baseUrl/conversations'));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<AdminConversation>.from(l.map((model) => AdminConversation.fromJson(model)));
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<List<AdminMessage>> getMessages(String conversationId) async {
    final response = await http.get(Uri.parse('\$baseUrl/conversations/\$conversationId/messages'));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<AdminMessage>.from(l.map((model) => AdminMessage.fromJson(model)));
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<AdminMessage> sendMessage(AdminMessage message) async {
    final response = await http.post(
      Uri.parse('\$baseUrl/messages'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(message.toJson()),
    );
    if (response.statusCode == 201) {
      return AdminMessage.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }
}
