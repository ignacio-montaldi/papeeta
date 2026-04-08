import 'package:papeeta/features/groups/data/models/group_image_dto.dart';
import 'package:papeeta/features/groups/domain/entities/group_image.dart';
import 'package:papeeta/global/enviroment.dart';

class GroupImageMapper {
  static GroupImage toEntity(GroupImageDto dto) {
    return GroupImage(
      id: dto.id,
      url: (dto.url.isNotEmpty)
          ? (dto.url.startsWith('http')
                ? dto.url
                : '${Enviroment.uploadsUrl}${dto.url}')
          : dto.url,
      position: dto.position,
    );
  }
}