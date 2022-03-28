import 'package:boilerplate/constants/strings.dart';
import 'package:mobx/mobx.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_manager/photo_manager.dart';

part 'video_photo_store.g.dart';

class VideoPhotoStore = _VideoPhotoStore with _$VideoPhotoStore;

abstract class _VideoPhotoStore with Store {
  @observable
  List<Medium> listMedium = [];

  @observable
  ObservableList<Medium> listMediumSelected = ObservableList.of([]);

  @observable
  bool isEditing = false;

  @observable
  Medium medium;

  @action
  findAll() async {
    try {
      final List<Album> imageAlbums = await PhotoGallery.listAlbums(
        mediumType: MediumType.image,
      );
      final myImageAlbum = imageAlbums.firstWhere(
          (element) => element.name == Strings.appName,
          orElse: () => null);
      final MediaPage imagePage = await myImageAlbum?.listMedia();
      listMedium = imagePage?.items ?? [];

      final List<Album> videoAlbums = await PhotoGallery.listAlbums(
        mediumType: MediumType.video,
      );
      final myVideoAlbum = videoAlbums.firstWhere(
          (element) => element.name == Strings.appName,
          orElse: () => null);
      final MediaPage videoPage = await myVideoAlbum?.listMedia();
      listMedium = [...listMedium, ...(videoPage?.items ?? [])];
      try {
        listMedium.sort((a, b) =>
            b.modifiedDate.microsecondsSinceEpoch -
            a.modifiedDate.microsecondsSinceEpoch);
      } catch (e) {}
    } catch (e) {
      print(e);
    }
  }

  @action
  setEditing(bool isEditing) {
    this.isEditing = isEditing;
    if (!isEditing) listMediumSelected.clear();
  }

  @action
  selectMedium(Medium medium) {
    if (listMediumSelected.contains(medium)) {
      listMediumSelected.remove(medium);
    } else {
      listMediumSelected.add(medium);
    }
  }

  @action
  selectAllMedium() {
    if (listMediumSelected.length != listMedium.length) {
      listMediumSelected.clear();
      listMediumSelected.addAll(listMedium);
    } else {
      listMediumSelected.clear();
    }
  }

  @action
  setMedium(Medium medium) {
    this.medium = medium;
  }

  @action
  deleteMedium() async {
    await PhotoManager.editor.deleteWithIds([medium.id]);
  }

  @action
  deleteMediumSelected() async {
    try {
      await PhotoManager.editor
          .deleteWithIds(listMediumSelected.map((e) => e.id).toList());
    } catch (e) {}
  }
}
