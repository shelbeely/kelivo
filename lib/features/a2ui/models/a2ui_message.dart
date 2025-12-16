/// A2UI Message Model
/// 
/// Represents a message containing an A2UI specification that can be
/// rendered into a dynamic user interface.
class A2uiMessage {
  /// Unique identifier for this A2UI message
  final String id;
  
  /// The A2UI specification (can be JSON string or Map)
  final dynamic specification;
  
  /// Timestamp when the message was created
  final DateTime timestamp;
  
  /// Optional metadata
  final Map<String, dynamic>? metadata;

  A2uiMessage({
    required this.id,
    required this.specification,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create from JSON
  factory A2uiMessage.fromJson(Map<String, dynamic> json) {
    return A2uiMessage(
      id: json['id'] as String,
      specification: json['specification'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'specification': specification,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  A2uiMessage copyWith({
    String? id,
    dynamic specification,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return A2uiMessage(
      id: id ?? this.id,
      specification: specification ?? this.specification,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}
