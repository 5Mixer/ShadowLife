let project = new Project('ShadowLife');

project.addLibrary("hxWebSockets")
project.addAssets('Assets')
project.addSources('Sources');
project.addParameter('-dce full');

resolve(project);
