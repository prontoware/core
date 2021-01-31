////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core Tests
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

class Camera3DTests implements IUnitTest
{
	void run()
	{
		Camera3D camera(1280, 800);
		test(camera.rtWidth == 1280);
		test(camera.rtHeight == 800);

		test(camera.position != null);
		test(camera.yawPitchRoll != null);

		test(camera.getPosition() != null);
		test(camera.getYawPitchRoll() != null);

		// move/orient in 3D by position and 'facing' direction
		camera.setCameraDirection(Vec3<f32>(11.0f, 12.0f, -13.0f), Vec3<f32>(0, 0, -1.0f));
		test(camera.position.compare(Vec3<f32>(11.0f, 12.0f, -13.0f)) == true);
		test(camera.getForwardVector().compare(Vec3<f32>(0, 0, -1.0f)) == true);

		// reset to 0,0,0 looking 0,0,1
		camera.reset();
		test(camera.getForwardVector().compare(Vec3<f32>(0, 0, 1.0f)) == true);

		// roll, yaw, pitch
		camera.setYawPitchRoll(Vec3<f32>((Math:PI / 2.0), 0, 0));
		test(Math:compare(camera.getYaw(), (Math:PI / 2.0)) == true);
		camera.setYawPitchRoll(Vec3<f32>(0, (Math:PI / 2.0), 0));
		test(Math:compare(camera.getPitch(), (Math:PI / 2.0)) == true);
		camera.setYawPitchRoll(Vec3<f32>(0, 0, (Math:PI / 2.0)));
		test(Math:compare(camera.getRoll(), (Math:PI / 2.0)) == true);

		// reset
		camera.setRenderTargetSize(1280, 800);
		camera.setCameraDirection(Vec3<f32>(0,0,0), Vec3<f32>(0, 0, 1.0f));

		// project
		Vec2<f32> screenXY(640, 400); // middle of screen should give us camera direction
		Ray3D<f32> ray = camera.projectRayFromScreen(screenXY);
		test(Math:compare(ray.dir[2], 1.0f, 0.1f) == true);

		// reset to 0,0,0 looking 0,0,1
		camera.reset();

		// look torward point
		camera.setCameraLookAt(Vec3<f32>(-10.0f, 0.0f, -10.0f), Vec3<f32>(0.0f, 0.0f, 0.0f));
		test(camera.getPosition().compare(Vec3<f32>(-10.0f, 0.0f, -10.0f)) == true);
		test(camera.getForwardVector().compare(Vec3<f32>(0.707f, 0, 0.707f), 0.1f) == true);
	}

}