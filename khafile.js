let project = new Project('ShadowLife');

project.addAssets('Assets')
project.addSources('Sources');
project.addParameter('-dce full');

resolve(project);
