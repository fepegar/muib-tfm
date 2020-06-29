
  % add needed function paths
  functiondir=which('image_registration.m');
  addpath([functiondir(1:end-length('image_registration.m')) '/low_level_examples'])

  % Get the volume data
  [Imoving,Istatic]=get_example_data;

  % Register the images
  Ireg = image_registration(Imoving,Istatic);

  % Show the results
  showcs3(Imoving);
  showcs3(Istatic);
  showcs3(Ireg);