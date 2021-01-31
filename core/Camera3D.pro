////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Camera3D
////////////////////////////////////////////////////////////////////////////////////////////////////

// A flexible 3D camera for rendering with the Pronto-Core GPU API. Tracks the orientation,
// position, fov etc. of where the viewer is in the 3D world (world space). The camera 
// position is defined by a single 3-space vector (x, y, z). The orientation is primarily
// stored as three vectors: the up, forward, and side vectors.
// 
// Like any practical 3D camera it picks some conventions for ease of use, described below.
//          
// The "home position" of the camera is (0,0,1) where the user would
// be looking straight down the Z+ axis. At this position, Yaw/Pitch would
// both be zero, because Y+ is the is the default "up" vector of the camera. 
// 
// XYZ cartesian convention: i.e. Standard camera vectors when in the "home position":
//          Y+
//          Up        Z+
//          |      Forward
//          |    /
//          |  /
//          |/
//          --------- Side (right) X+
//
// Yaw/Pitch/Roll convention:
//
//         Yaw
//          Y+       Roll
//          |      Z+
//          |    /
//          |  /
//          |/
//          --------- X+ Pitch
//
// Pitch: Around the XZ plane, starting from Z+ clockwise (positive) to the right. 0 to 2PI range.
// Yaw:   Angle between XZ plane and the up (Y+) vector. 0 to PI/2 in the Y+ halfspace, 0 to -PI/2 in the Y- halfspace.
// Roll:  Rotation around the forward vector (Pitch/Yaw) going clockwise (positive) to the right. 0 to 2PI range.
class Camera3D
{
	const u8 PROJECTION_PERSPECTIVE  = 0;
	const u8 PROJECTION_ORTHOGRAPHIC = 1;

	shared Vec3<f32> X_AXIS_POS(1.0f, 0.0f, 0.0f);
	shared Vec3<f32> X_AXIS_NEG(-1.0f, 0.0f, 0.0f);
	shared Vec3<f32> Y_AXIS_POS(0.0f, 1.0f, 0.0f);
	shared Vec3<f32> Y_AXIS_NEG(1.0f, -1.0f, 0.0f);
	shared Vec3<f32> Z_AXIS_POS(0.0f, 0.0f, 1.0f);
	shared Vec3<f32> Z_AXIS_NEG(0.0f, 0.0f, -1.0f);

	// Primary 3D properties
	Vec3<f32> position();
	Vec3<f32> yawPitchRoll();

	// Image space properties
	u8 projectionType = 0; // PROJECTION_PERSPECTIVE;
	u32 rtWidth       = 0; // render target width in pixels
	u32 rtHeight      = 0; // render target height in pixels
	f32 aspectRatio   = 0.0;
	f32 fov           = 0;
	f32 nearClipPlane = 0.1f;
	f32 farClipPlane  = 1000.0f;

	// Only used for orthographic
	f32 orthoCameraWidth  = 0; // world units
	f32 orthoCameraHeight = 0; // world units

	// Cached transforms
	Matrix4x4<f32> cameraMatrix();
	Matrix4x4<f32> cameraInverseMatrix();
	Matrix4x4<f32> projectionMatrix();
	Matrix4x4<f32> postProjectionMatrix();
	Matrix4x4<f32> projectionInverseMatrix();
	Matrix4x4<f32> cameraProjectionMatrix();
	Matrix4x4<f32> cameraProjectionInverseMatrix();
	Matrix4x4<f32> overlayMatrix();
	Matrix4x4<f32> overlayScreenMatrix();

	// Camera at 0,0,0 looking down Z+ axis.
	void constructor()
	{
		reset();
	}

	// Basic valid camera.
	void constructor(u32 rtWidth, u32 rtHeight)
	{
		reset();

		this.rtWidth     = rtWidth;
		this.rtHeight    = rtHeight;
		this.aspectRatio = rtWidth / f32(rtHeight);

		this.updateMatrices();
	}

	// Copy constructor.
	void constructor(Camera3D c)
	{
		copy(c);
	}

	// Origin, yaw-pitch-roll, forward/side/up vectors and FOV.
	String<u8> toString()
	{
		String<u8> s = String<u8>(64);

		Vec3<f32> ypr = this.getYawPitchRoll();
		
		s.append("Camera:\n");
		s.append(" Pos: ");
		s.append(this.position.toString(1));
		s.append("\n");
		s.append(" YPR: ");
		s.append(this.getYawPitchRoll().toString(1));
		s.append("\n");
		s.append(" Forward: ");
		s.append(this.getForwardVector().toString(1));
		s.append("\n");
		s.append(" Side: ");
		s.append(this.getSideVector().toString(1));
		s.append("\n");
		s.append(" Up: ");
		s.append(this.getUpVector().toString(1));
		s.append("\n");
		s.append(" FOV:  ");
		s.append(this.fov);
		s.append("\n");

		return s;
	}

	// Reset to 0,0,0 position looking down Z+.
	void reset()
	{
		// Primary 3D properties
		this.position.set(0.0, 0.0, 0.0); //where the camera (AKA view point/eye point) is positioned in space
		this.yawPitchRoll.set(0.0f, 0.0f, 0.0f); //looking down Z+

		// Image space properties
		this.rtWidth        = 640;
		this.rtHeight       = 480;
		this.aspectRatio    = rtWidth / f32(rtHeight);
		this.projectionType = PROJECTION_PERSPECTIVE;
		this.fov            = Math:PI / 2.0f; // field of view in radians
		this.nearClipPlane  = 0.1f;   // anything closer to position + this is not rendered
		this.farClipPlane   = 1000.0f;// anything farther then position + this is not rendered

		// Only used for orthographic
		this.orthoCameraWidth  = 1.0f; // world units
		this.orthoCameraHeight = 1.0f; // world units

		this.updateMatrices();
	}

	// Copy passed-in camera.
	void copy(Camera3D c)
	{
		// Primary 3D properties
		this.position.copy(c.position);
		this.yawPitchRoll.copy(c.yawPitchRoll);

		// Image space properties
		this.rtWidth        = c.rtWidth;
		this.rtHeight       = c.rtHeight;
		this.aspectRatio    = c.aspectRatio;
		this.projectionType = c.projectionType;
		this.fov            = c.fov;
		this.nearClipPlane  = c.nearClipPlane;
		this.farClipPlane   = c.farClipPlane;

		// Only used for orthographic
		this.orthoCameraWidth   = c.orthoCameraWidth;
		this.orthoCameraHeight  = c.orthoCameraHeight;

		// Generate cached matrices
		this.updateMatrices();
	}

	// Set the render target (image) size in pixels.
	void setRenderTargetSize(u32 width, u32 height)
	{
		this.rtWidth     = width;
		this.rtHeight    = height;
		this.aspectRatio = width / f32(height);

		this.updateMatrices();
	}

	// In world units, set the orthographic camera eye size.
	void setOrthoCameraSize(f32 orthoWidth, f32 orthoHeight)
	{
		this.orthoCameraWidth  = orthoWidth;
		this.orthoCameraHeight = orthoHeight;

		this.updateMatrices();
	}

	// Camera vertical field of view.
	void setFieldOfView(f32 fovRadians)
	{
		this.fov = fovRadians;

		this.updateMatrices();
	}

	// Camera origin.
	Vec3<f32> getPosition()
	{
		return Vec3<f32>(this.position);
	}

	// Camera origin.
	void setPosition(Vec3<f32> position)
	{
		this.position.copy(position);
		this.updateMatrices();
	}

	// Camera orientation.
	void setYawPitchRoll(Vec3<f32> yawPitchRoll)
	{
		this.yawPitchRoll.copy(yawPitchRoll);
		this.updateMatrices();
	}

	// Camera orientation.
	Vec3<f32> getYawPitchRoll()
	{
		return Vec3<f32>(yawPitchRoll);
	}

	// Radians around the "up" vector.
	f32 getYaw()
	{
		return yawPitchRoll[0];
	}

	// Rotate around the "up" vector.
	void setYaw(f32 radians)
	{
		// keep yaw in 0 to 2PI range
		radians = constrainTo2PI(radians);
		yawPitchRoll.p[0] = radians;
		updateMatrices();
	}

	// Rotate from the "ground" plane.
	f32 getPitch()
	{
		return yawPitchRoll[1];
	}

	// Radians from the "ground" plane to the forward vector.
	void setPitch(f32 radians)
	{
		f32 piHalf = Math:PI / 2.0f;

		// prevent roll over
		if(radians >= piHalf)
			radians = piHalf - 0.00001f;

		if(radians <= (-1.0f * piHalf))
			radians = (-1.0f * piHalf) + 0.00001f;

		yawPitchRoll.p[1] = radians;
		updateMatrices();
	}

	// Radians around the forward vector, in radians, from Y+.
	f32 getRoll()
	{
		return yawPitchRoll[2];
	}

	// Roll around the forward vector.
	void setRoll(f32 radians)
	{
		// keep roll in 0 to 2PI range
		radians = constrainTo2PI(radians);
		yawPitchRoll.p[2] = radians;
		updateMatrices();
	}

	// Rotate the camera to look in a specific direction from a provided origin.
	void setCameraDirection(Vec3<f32> position, Vec3<f32> direction) { setCameraDirection(position, direction, 0.0f); }

	// Rotate the camera to look in a specific direction from a provided origin.
	void setCameraDirection(Vec3<f32> position, Vec3<f32> direction, f32 roll)
	{
		Vec3<f32> forward = getForwardVector();
		Vec3<f32> side    = getSideVector();
		Vec3<f32> up      = getUpVector();

		this.position.copy(position);
		forward.copy(direction);
		forward.normalize();

		if(Math:compare(roll, 0.0f, 0.00001f) == false)
		{
			// side vector is always parallel to the XY plane when there is no roll
			side = this.getGroundVector(forward);
			side.invert();
			
			// side gets rotated
			Matrix4x4<f32> rollMatrix();
			rollMatrix.setAsRotationMatrix(forward, roll);
			rollMatrix.mul(side, side);

			// up gets calculated
			up = axisBetweenVectors(forward, side);
		}
		else
		{
			// side vector is always parallel to the XY plane when there is no roll
			side = this.getGroundVector(forward);
			side.invert();
			up   = axisBetweenVectors(forward, side);
		}

		// extract yaw/pitch/roll from forward/up
		this.yawPitchRoll    = Camera3D:getYawPitchRoll(forward, up);
		this.yawPitchRoll[2] = roll;

		updateMatrices();
	}

	// Rotate the camera to look at a specific point in space from a provided origin.
	void setCameraLookAt(Vec3<f32> position, Vec3<f32> lookAt) { setCameraLookAt(position, lookAt, 0.0f); }

	// Rotate the camera to look at a specific point in space from a provided origin.
	void setCameraLookAt(Vec3<f32> position, Vec3<f32> lookAt, f32 roll)
	{
		Vec3<f32> dir = lookAt - position;
		dir.normalize();

		setCameraDirection(position, dir, roll);
	}

	// The direction the camera is facing.
	Vec3<f32> getForwardVector()
	{
		// calculate forward vector
		Vec3<f32> fwd = Camera3D:setFromYawPitch(yawPitchRoll[0], yawPitchRoll[1], 1.0f);
		return fwd;
	}

	// The direction "up" direction is related to the roll value.
	Vec3<f32> getUpVector()
	{
		Vec3<f32> fwd = getForwardVector();

		// rotate to be 90* from yaw/pitch
		Vec3<f32> up = Camera3D:setFromYawPitch(yawPitchRoll[0] + Math:PI, (Math:PI / 2.0f) - yawPitchRoll[1], 1.0f);
		up.normalize();

		if(Math:compare(yawPitchRoll[2], 0.0f) != true)
		{
			up = rotateAroundVector(up, fwd, yawPitchRoll[2]);
			up.normalize();
		}
		
		return up;
	}

	// The side vector is one of the two possible cross products of forward/up.
	Vec3<f32> getSideVector()
	{
		Vec3<f32> fwd  = getForwardVector();

		// same as forward vector, but yaw + 90* and roll applied
		Vec3<f32> side = Camera3D:setFromYawPitch(yawPitchRoll[0] + (Math:PI / 2.0f), 0.0f, 1.0f);
		side.normalize();
		
		if(Math:compare(yawPitchRoll[2], 0.0f) != true)
		{
			side = rotateAroundVector(side, fwd, yawPitchRoll[2]);
			side.normalize();
		}

		return side;
	}

	// Always provides vector along the XZ plane.
	Vec3<f32> getGroundVector(Vec3<f32> lookDirection)
	{
		//same as forward vector, but ignore pitch/roll
		Vec3<f32> ground = setFromYawPitch(yawPitchRoll[0] - (Math:PI / 2.0f), 0.0f, 1.0f);

		return ground;
	}

	// Of the two possible cross product vectors, this returns the one in the Y+ space.
	Vec3<f32> getVerticalVector(Vec3<f32> lookDirection, Vec3<f32> groundVector)
	{
		// should this be cached? (i.e. don't pass in lookDirection)

		// 3 'V' Vertical vector perpendicular to both D and G
		Vec3<f32> verticalVector(lookDirection);
		verticalVector.cross(groundVector);

		if(verticalVector.p[1] < 0.0f)
			verticalVector.p[1] *= -1.0f;

		return verticalVector;
	}

	// Project a world point onto the virtual camera screen.
	Vec4<f32> transformWorldToScreen(Vec3<f32> worldXYZ)
	{
		Vec4<f32> vp(worldXYZ); //x,y,z,1.0
		
		// transform from world to virtual viewport space
		this.cameraProjectionMatrix.mul(vp, vp);
		
		//do w divide (AKA perspective divide)
		vp.p[0] = vp.p[0] / vp.p[3];
		vp.p[1] = vp.p[1] / vp.p[3];
		vp.p[2] = vp.p[2] / vp.p[3];
		vp.p[3] = 1.0f;

		//transform from virtual viewport space to screen space
		vp.p[0] = ((vp.p[0] / 2.0f) * this.rtWidth) + (this.rtWidth/2);
		vp.p[1] = (((-1.0f * vp.p[1]) / 2.0f) * this.rtHeight) + (this.rtHeight/2);

		return vp;
	}

	// Project a viewport point to the virtual camera screen.
	Vec3<f32> viewportPointToScreen(Vec3<f32> viewportXYZ)
	{
		Vec3<f32> v();
		v.p[0] = ((viewportXYZ.p[0] / 2.0f) * this.rtWidth) + (this.rtWidth/2);
		v.p[1] = (((-1.0f * viewportXYZ.p[1]) / 2.0f) * this.rtHeight) + (this.rtHeight/2);
		v.p[2] = viewportXYZ.p[2];
		
		return v;
	}

	// For picking objects, project a point from the screen into the world using the natural projection vector for the ray direction.
	Ray3D<f32> projectRayFromScreen(Vec2<f32> screenXY)
	{
		Ray3D<f32> ray();

		Vec3<f32> v();
		v.p[0] =  (((2.0f * screenXY.p[0]) / this.rtWidth) - 1.0f) / this.projectionMatrix.m[0];
		v.p[1] = -1.0f * (((2.0f * screenXY.p[1]) / this.rtHeight) - 1.0f) / this.projectionMatrix.m[5];
		v.p[2] = 1.0f;

		ray.dir.p[0] = (v.p[0] * this.cameraInverseMatrix.m[0]) + (v.p[1] * this.cameraInverseMatrix.m[4]) + (v.p[2] * this.cameraInverseMatrix.m[8]);
		ray.dir.p[1] = (v.p[0] * this.cameraInverseMatrix.m[1]) + (v.p[1] * this.cameraInverseMatrix.m[5]) + (v.p[2] * this.cameraInverseMatrix.m[9]);
		ray.dir.p[2] = (v.p[0] * this.cameraInverseMatrix.m[2]) + (v.p[1] * this.cameraInverseMatrix.m[6]) + (v.p[2] * this.cameraInverseMatrix.m[10]);
		ray.dir.normalize();

		ray.pt.p[0] = this.cameraInverseMatrix.m[12];
		ray.pt.p[1] = this.cameraInverseMatrix.m[13];
		ray.pt.p[2] = this.cameraInverseMatrix.m[14];

		return ray;
	}

	// Utility for picking a point on a plane from the screen.
	bool getScreenToPlanePOI(Vec3<f32> ptOnPlane, Vec2<f32> screenPos, Vec3<f32> poiOut)
	{
		// Make a plane parallel to the camera but which intersects ptOnPlane
		Plane<f32> axisPlane(getForwardVector(), ptOnPlane);

		// Shoot ray from screen into scene
		Ray3D<f32> cameraRay = projectRayFromScreen(screenPos);

		// Check for intersection (could be false if camera facing away from plane, i.e. plane is behind camera)
		bool poiReal = axisPlane.intersectRay(cameraRay, poiOut);
		
		return poiReal;	
	}

	// Computes all cached matrices from camera properties.
	void updateMatrices()
	{
		Vec3<f32> forward = getForwardVector();
		Vec3<f32> side    = getSideVector();
		Vec3<f32> up      = getUpVector();

		// includes roll
		this.cameraMatrix.setAsLeftHandedLookAtMatrix(this.position, forward, side, up);
		this.cameraInverseMatrix = this.cameraMatrix.inverse();

		// projection depends on projection type
		if(this.projectionType == PROJECTION_PERSPECTIVE)
		{
			// projection matrix
			this.aspectRatio = this.rtWidth / f32(this.rtHeight);
			this.projectionMatrix.setAsLeftHandedPerspectiveMatrix(this.fov, this.aspectRatio, this.nearClipPlane, this.farClipPlane);
			this.projectionInverseMatrix = this.projectionMatrix.inverse();
		}
		else if(this.projectionType == PROJECTION_ORTHOGRAPHIC)
		{
			this.projectionMatrix.setAsLeftHandedOrthographicMatrix(orthoCameraWidth, orthoCameraHeight, this.nearClipPlane, this.farClipPlane);
			this.projectionInverseMatrix = this.projectionMatrix.inverse();
		}

		// camera + projection
		this.cameraProjectionMatrix.copy(this.cameraMatrix); 
		this.cameraProjectionMatrix.mul(this.projectionMatrix);
		this.cameraProjectionMatrix.mul(this.postProjectionMatrix);
		this.cameraProjectionInverseMatrix = this.cameraProjectionMatrix.inverse();

		// overlay
		this.overlayMatrix.setAsLeftHandedOrthographicMatrix(this.rtWidth, this.rtHeight, 0.0f, 1.0f);

		// overlay to windows screen coordinates (origin in top-left, Y+ down)
		Matrix4x4<f32> overlayTranslateMatrix();
		overlayTranslateMatrix.setAsTranslationMatrix(Vec3<f32>(-1.0f * (this.rtWidth / 2.0f), this.rtHeight / 2.0f, 0.0f));

		Matrix4x4<f32> overlayFlipMatrix();
		overlayFlipMatrix.setAsScaleMatrix(Vec3<f32>(1.0f, -1.0f, 1.0f));

		Matrix4x4<f32> overlayTransformMatrix(overlayFlipMatrix);
		overlayTransformMatrix.mul(overlayTranslateMatrix);

		this.overlayScreenMatrix.copy(overlayTransformMatrix);
		this.overlayScreenMatrix.mul(this.overlayMatrix);
	}

	// Validate the camera is in a known good state.
	bool isValid()
	{
		/* TODO
		if(this.position.isValid() == false)
			return false;
		
		if(this.getForwardVector().isValid() == false)
			return false;
		
		if(this.getUpVector().isValid() == false)
			return false;
		
		if(this.cameraMatrix.isValid() == false)
			return false;
		
		if(this.projectionMatrix.isValid() == false)
			return false;
		
		if(this.overlayMatrix.isValid() == false)
			return false;
		
		if(this.cameraInverseMatrix.isValid() == false)
			return false;
		
		if(this.projectionInverseMatrix.isValid() == false)
			return false;
		
		if(this.cameraProjectionInverseMatrix.isValid() == false)
			return false;*/
		
		return true;
	}

	// Move in the direction of the forward vector.
	void moveForward(f32 amount)
	{
		Vec3<f32> origin(this.getPosition());
		Vec3<f32> direction(this.getForwardVector());
		Vec3<f32> ground    = this.getGroundVector(direction);
		Vec3<f32> vertical  = this.getVerticalVector(direction, ground);

		// move along "forward" direction
		Vec3<f32> t = direction * amount;
		origin += t;

		this.setCameraDirection(origin, direction, this.getRoll());
	}

	// Move "left" or "right" along the side vector.
	void moveSideways(f32 amount)
	{
		Vec3<f32> origin(this.getPosition());
		Vec3<f32> direction(this.getForwardVector());
		Vec3<f32> ground    = this.getGroundVector(direction);
		Vec3<f32> vertical  = this.getVerticalVector(direction, ground);

		// move along "sideways" direction
		Vec3<f32> t = ground * amount;
		origin += t;

		this.setCameraDirection(origin, direction, this.getRoll());
	}

	// Move "up" or "down" along the vertical vector.
	void moveVertically(f32 amount)
	{
		Vec3<f32> origin(this.getPosition());
		Vec3<f32> direction(this.getForwardVector());
		Vec3<f32> ground    = this.getGroundVector(direction);
		Vec3<f32> vertical  = this.getVerticalVector(direction, ground);

		// move along "vertical" direction
		Vec3<f32> t = vertical * amount;
		origin += t;

		this.setCameraDirection(origin, direction, this.getRoll());
	}

	// Rotate around the vertical vector.
	void rotateYaw(f32 amount)
	{
		this.setYaw(this.getYaw() + amount);
	}

	// Rotate from the ground plane.
	void rotatePitch(f32 amount)
	{
		this.setPitch(this.getPitch() + amount);
	}

	// Rotate around the forward vector.
	void rotateRoll(f32 amount)
	{
		this.setRoll(this.getRoll() + amount);
	}

	// Clamp angle.
	f32 constrainTo2PI(f32 radians)
	{
		if(radians >= (2.0f * Math:PI))
		{
			i32 factors = Math:floor(radians / (2.0f * Math:PI));
			radians = radians - (factors * (2.0f * Math:PI));
		}

		if(radians < 0.0f)
		{
			f32 absRadians = Math:abs(radians);
			if(absRadians >= (2.0f * Math:PI))
			{
				i32 factors = Math:floor(absRadians / (2.0f * Math:PI));
				absRadians = absRadians - (factors * (2.0f * Math:PI));
				radians = -1.0f * absRadians;
			}

			radians = (2.0f * Math:PI) + radians; //adding negative
		}

		return radians;
	}

	// Set vector from yaw/pitch
	shared Vec3<f32> setFromYawPitch(f32 yaw, f32 pitch, f32 len)
	{
		Vec3<f32> startVec(0.0f, 0.0f, 1.0f); //starting location where yaw=0 pitch=0

		// Yaw rotation around y
		Vec3<f32> yawVec = rotateAroundVector(startVec, Y_AXIS_POS, -1.0f * yaw);
		yawVec.normalize();

		// Pitch rotation from XZ plane
		Vec3<f32> pitchAxis   = Camera3D:axisBetweenVectors(yawVec, Y_AXIS_POS);
		Vec3<f32> yawPitchVec = rotateAroundVector(yawVec, pitchAxis, -1.0f * pitch);
		yawPitchVec.normalize();

		// scale to final length
		yawPitchVec *= len;

		return yawPitchVec;
	}

	// Extract yaw/pitch from vector.
	shared Vec3<f32> getYawPitch(Vec3<f32> from)
	{
		f32 yaw   = 0.0f;
		f32 pitch = 0.0f;

		// must be unit circle for angle calculations
		Vec3<f32> dir(from);
		dir.normalize();

		// Yaw
		Vec2<f32> yawDir(dir[0], dir[2]);
		yawDir.normalize();
		if(Math:compare(yawDir[0], 0) == true && Math:compare(yawDir[1], 0) == true)
		{
			// Special case, x/y coordinates are zero, meaning this vector is Y_AXIS_POS or Y_AXIS_NEG,
			// either way, the yaw is 0.
			yaw = 0.0f;
		}
		else
		{
			// yaw: the angle round the Y-axis starting from the Z+ axis.
			yaw = yawDir.angleBetweenVectors(Vec2<f32>(0.0f, 1.0f)); //Vec2:Y_AXIS_POS);
		}
		
		// Pitch: the angle between the ground plane and the forward vector
		if(from.compare(Y_AXIS_NEG) == true)
		{
			pitch = -1.0f * (Math:PI / 2.0f);
		}
		else if(from.compare(Y_AXIS_POS) == true)
		{
			pitch = (Math:PI / 2.0f);
		}
		else
		{
			Vec2<f32> v0(0.0f, dir[1]);
			if(v0.isZero() == true)
			{
				pitch = 0.0f;
			}
			else
			{
				// XXX: don't know that hypotenuse is 1 (it is in 3D, but not 2D).

				// Can figure out x by using the yaw (XZ projection)
				Vec2<f32> xzDir(dir[0], dir[2]); // don't normalize
				f32 x = xzDir.length();

				v0[0] = x;
				v0.normalize();

				// Because the range is zero to PI for yaw, and angles are measured by angleBetweenVectors() as
				// clockwise positive, we need to handle four separate quadrants:

				// X will always be positive, so just do two half-drants
				// Y+
				if(v0[1] >= 0.0f)
					pitch = -1.0f * v0.angleBetweenVectors(Vec2<f32>(1.0f, 0.0f)); // Vec2::X_AXIS_POS);
				// Y-
				else
					pitch = -1.0f * v0.angleBetweenVectors(Vec2<f32>(1.0f, 0.0f)); // Vec2::X_AXIS_POS);
			}
		}

		return Vec3<f32>(yaw, pitch, 0.0f);
	}

	// Extract yaw, pitch, roll using provided up reference vector.
	shared Vec3<f32> getYawPitchRoll(Vec3<f32> from, Vec3<f32> up)
	{
		f32 yaw   = 0.0f;
		f32 pitch = 0.0f;
		f32 roll  = 0.0f;

		// must be unit circle for angle calculations
		Vec3<f32> dir(from);
		dir.normalize();

		// Yaw
		Vec2<f32> yawDir(dir[0], dir[2]);
		yawDir.normalize();
		if(Math:compare(yawDir[0], 0) == true && Math:compare(yawDir[1], 0) == true)
		{
			// Special case, x/y coordinates are zero, meaning this vector is Y_AXIS_POS or Y_AXIS_NEG,
			// either way, the yaw is 0.
			yaw = 0.0f;
		}
		else
		{
			// yaw: the angle round the Y-axis starting from the Z+ axis.
			yaw = yawDir.angleBetweenVectors(Vec2<f32>(0.0f, 1.0f)); //Vec2::Y_AXIS_POS);
		}
		
		// Pitch: the angle between the ground plane and the forward vector
		if(from.compare(Y_AXIS_NEG) == true)
		{
			pitch = -1.0f * (Math:PI / 2.0f);
		}
		else if(from.compare(Y_AXIS_POS) == true)
		{
			pitch = (Math:PI / 2.0f);
		}
		else
		{
			Vec2<f32> v0(0.0f, dir[1]);
			if(v0.isZero() == true)
			{
				pitch = 0.0f;
			}
			else
			{
				// XXX: don't know that hypotenuse is 1 (it is in 3D, but not 2D).

				// Can figure out x by using the yaw (XZ projection)
				Vec2<f32> xzDir = Vec2<f32>(dir[0], dir[2]); //don't normalize
				f32 x = xzDir.length();

				v0[0] = x;
				v0.normalize();

				// Because the range is zero to PI for yaw, and angles are measured by angleBetweenVectors() as
				// clockwise positive, we need to handle four separate quadrants:

				// X will always be positive, so just do two half-drants
				// Y+
				if(v0[1] >= 0.0f)
					pitch = -1.0f * v0.angleBetweenVectors(Vec2<f32>(1.0f, 0.0f));//Vec2::X_AXIS_POS);
				// Y-
				else
					pitch = -1.0f * v0.angleBetweenVectors(Vec2<f32>(1.0f, 0.0f));//Vec2::X_AXIS_POS);
			}
		}

		// roll: the angle between the Y+ axis and the up vector (along the XY plane)
		
		// TODO rotate the up vector using yaw/pitch values just calculated so that direction
		// points right down Z+ axis, and then we can use XY plane for figuring out roll using
		// the up direction.
		Vec3<f32> upNormalized(up);
		upNormalized.normalize();

		Matrix4x4<f32> cancelYawPitchMatrix = makeYawPitchRollMatrix(Vec3<f32>(0, 0, 0), Vec3<f32>(-1.0f * yaw, -1.0f * pitch, 0.0f));

		//Vec3<f32> upAlignedToXZ = upNormalized * cancelYawPitchMatrix;
		Vec3<f32> upAlignedToXZ(upNormalized);
		cancelYawPitchMatrix.mul(upAlignedToXZ);
		upAlignedToXZ.normalize();

		Vec2<f32> rollDir(upAlignedToXZ[0], upAlignedToXZ[1]);
		rollDir.normalize();
		if(Math:compare(yawDir[0], 0) == true && Math:compare(yawDir[1], 0) == true)
		{
			// Special case, x/y coordinates are zero, meaning this vector is Y_AXIS_POS or Y_AXIS_NEG,
			// either way, the yaw is 0.
			roll = 0.0f;
		}
		else
		{
			//yaw: the angle round the Y-axis starting from the Z+ axis.
			roll = rollDir.angleBetweenVectors(Vec2<f32>(0.0f, 1.0f)); //Vec2::Y_AXIS_POS);
		}

		return Vec3<f32>(yaw, pitch, roll);
	}

	// Rotate this vector around an arbitrary axis, returning the new, transformed vector.
	shared Vec3<f32> rotateAroundVectorClockwise(Vec3<f32> from, Vec3<f32> axis, f32 radians)
	{
		Vec3<f32> a(axis);
		a.normalize();
		Matrix4x4<f32> rot();
		rot.setAsRotationMatrix(a, -1.0f * radians);
		Vec3<f32> res = rot.mul(from);
		return res;
	}

	// Rotate this vector around an arbitrary axis, returning the new, transformed vector.
	shared Vec3<f32> rotateAroundVector(Vec3<f32> from, Vec3<f32> axis, f32 radians)
	{
		Vec3<f32> a(axis);
		a.normalize();
		Matrix4x4<f32> rot();
		rot.setAsRotationMatrix(a, radians);
		Vec3<f32> res = rot.mul(from);
		return res;
	}

	// Cross product with check for perpendicular vectors.
	shared Vec3<f32> axisBetweenVectors(Vec3<f32> from, Vec3<f32> v2)
	{
		Vec3<f32> a(from);
		a.normalize();
		Vec3<f32> b(v2);
		b.normalize();

		a.cross(b);
		a.normalize();

		// The cross product can be zero when the vectors point in the same direction or opposite directions. In practice,
		// we still want a valid axis and we can arbitraly choose a valid one.
		if(Math:compare(a.length(), 0.0f, 0.1f) == true)
		{
			/*
			// X dominant:
			if((a.compare(Vec3(1, 0, 0)) || a.compare(Vec3(-1, 0, 0))) && (b.compare(Vec3(1, 0, 0)) || b.compare(Vec3(-1, 0, 0))))
				axis = Vec3::Y_AXIS_POS;
			// Y dominant:
			else if((a.compare(Vec3(0, 1, 0)) || a.compare(Vec3(0, -1, 0))) && (b.compare(Vec3(0, 1, 0)) || b.compare(Vec3(0, -1, 0))))
				axis = Vec3::X_AXIS_POS;
			// Z dominant:
			else if((a.compare(Vec3(0, 0, 1)) || a.compare(Vec3(0, 0, -1))) && (b.compare(Vec3(0, 0, 1)) || b.compare(Vec3(0, 0, -1))))
				axis = Vec3::Y_AXIS_POS;
			else
			{
				// both vectors are zero
				axis = Vec3::Y_AXIS_POS;
			}*/

			a.set(0, 1, 0);
		}

		return a;
	}

	// Yaw, pitch, roll transform matrix.
	shared Matrix4x4<f32> makeYawPitchRollMatrix(Vec3<f32> startYPR, Vec3<f32> endYPR)
	{
		Matrix4x4<f32> rotMat();

		Vec3<f32> deltaYPR = endYPR - startYPR;

		Vec3<f32> fwdAxis    = getYawPitch(startYPR); // starting location
		Vec3<f32> sideAxis   = getYawPitch(Vec3<f32>(startYPR[0] + (Math:PI / 2.0f), 0, 0)); // starting side axis (no roll consideration needed)
		Vec3<f32> endFwdAxis = getYawPitch(endYPR);

		// apply yaw
		Matrix4x4<f32> yawMatrix();
		yawMatrix.setAsRotationMatrix(Y_AXIS_POS, -1.0f * deltaYPR[0]);
		fwdAxis  = yawMatrix.mul(fwdAxis);
		sideAxis = yawMatrix.mul(sideAxis);

		//VERT(Math:compare(fwdAxis.dot(sideAxis), 0.0f, 0.1f)); // confirm orthogonal
		
		// apply pitch
		Matrix4x4<f32> pitchMatrix();
		pitchMatrix.setAsRotationMatrix(sideAxis, deltaYPR[1]);
		fwdAxis = pitchMatrix.mul(fwdAxis);

		//VERT(Math:compare(fwdAxis.dot(sideAxis), 0.0f, 0.1f)); // confirm orthogonal

		// roll
		Matrix4x4<f32> rollMatrix();
		if(Math:compare(deltaYPR[2], 0.0f, 0.005f) == false)
		{
			rollMatrix.setAsRotationMatrix(fwdAxis, -1.0f * deltaYPR[2]);
		}

		// combine yaw/pitch/roll
		//rotMat = yawMatrix * pitchMatrix * rollMatrix;
		rotMat.mul(yawMatrix);
		rotMat.mul(pitchMatrix);
		rotMat.mul(rollMatrix);

		return rotMat;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// CameraMover
////////////////////////////////////////////////////////////////////////////////////////////////////

// Animated movement/rotation of a camera with time (position / rotation).
// Call update() and applyToCamera() to get full input cycle.
class CameraMover
{
	Camera3D  camera         = null; // camera we are moving
	Vec3<f32> rotateSpeed(0, 0, 0);  // yaw, pitch, roll - zero indicates no change
	Vec3<f32> moveSpeed(0, 0, 0);    // forward, side, up - zero indicates no change
	f64       lastUpdateTime = 0;
	Vec3<f32> orientationOffset(); // accumulated from input
	Vec3<f32> movementOffset();    // accumlated from input

	// Construct to move passed-in camera.
	void constructor(Camera3D camera)
	{
		this.camera = camera;
		this.lastUpdateTime = 0.0; // last time we were updated
	}

	// Update movement/orientation offsets based on elapsedTime. time in milliseconds.
	void update(f64 time)
	{
		if(this.camera == null)
			return;

		if(Math:compare(this.lastUpdateTime, 0.0) == true) // first update?
			this.lastUpdateTime = time;

		f64 timePassed = (time - this.lastUpdateTime);
		this.lastUpdateTime = time;

		if(Math:compare(timePassed, 0.0, 0.00000) == true)
			return; // no measurable time elapsed since last update

		Vec3<f32> direction(camera.getForwardVector());
		Vec3<f32> ground    = camera.getGroundVector(camera.getForwardVector());
		Vec3<f32> vertical  = camera.getVerticalVector(camera.getForwardVector(), ground);

		Vec3<f32> tempVec(0, 0, 0);

		// movement change
		Vec3<f32> movementChange();
		if(Math:compare(this.moveSpeed.p[0], 0.0f, 0.0001f) == false)
		{
			// move along "forward" direction
			tempVec.copy(direction);
			tempVec = tempVec.multiply((this.moveSpeed.p[0] / 1000.0f) * timePassed);
			movementChange += tempVec;
		}
		if(Math:compare(this.moveSpeed.p[1], 0.0f, 0.0001f) == false)
		{
			// move along "sideways" direction
			tempVec.copy(ground);
			tempVec = tempVec.multiply((this.moveSpeed.p[1] / 1000.0f) * timePassed);
			movementChange += tempVec;
		}
		if(Math:compare(this.moveSpeed.p[2], 0.0f, 0.0001f) == false)
		{
			// move along "sideways" direction
			tempVec.copy(vertical);
			tempVec = tempVec.multiply((this.moveSpeed.p[2] / 1000.0f) * timePassed);
			movementChange += tempVec;
		}

		// orientation change
		Vec3<f32> orientationChange();
		if(Math:compare(this.rotateSpeed.p[0], 0.0f, 0.0001f) == false)
		{
			f32 rotateRadians = (this.rotateSpeed.p[0] / 1000.0f) * timePassed;
			orientationChange[0] += rotateRadians;
		}
		if(Math:compare(this.rotateSpeed.p[1], 0.0f, 0.0001f) == false)
		{
			// magnitude of direction
			f32 rotateRadians = (this.rotateSpeed.p[1] / 1000.0f) * timePassed;
			orientationChange[1] += rotateRadians;
		}
		if(Math:compare(this.rotateSpeed.p[2], 0.0f, 0.0001f) == false)
		{
			// magnitude of direction
			f32 rotateRadians = (this.rotateSpeed.p[2] / 1000.0f) * timePassed;
			orientationChange[2] += rotateRadians;
		}

		movementOffset += movementChange;
		orientationOffset += orientationChange;
	}

	// Apply the movement/orientation offsets to the current camera
	void applyToCamera()
	{
		camera.setPosition(movementOffset);
	}

	// Set camera on mover. Resets movement control.
	void setCamera(Camera3D camera)
	{
		this.camera         = camera;
		this.lastUpdateTime = 0;
	}

	// Start/adjust animated movement (progresses over time).
	void startMovingForward(f32 unitsPerSecond)
	{
		this.moveSpeed[0] = unitsPerSecond;
	}

	// Stop animated movement (progresses over time).
	void stopMovingForward()
	{
		this.moveSpeed[0] = 0.00000f;
	}

	// Start/adjust animated movement (progresses over time).
	void startMovingSideways(f32 unitsPerSecond)
	{
		this.moveSpeed[1] = unitsPerSecond;
	}

	// Stop animated movement (progresses over time).
	void stopMovingSideways()
	{
		this.moveSpeed[1] = 0.00000f;
	}

	// Start/adjust animated movement (progresses over time).
	void startMovingVertically(f32 unitsPerSecond)
	{
		this.moveSpeed[2] = unitsPerSecond;
	}

	// Stop animated movement (progresses over time).
	void stopMovingVertically()
	{
		this.moveSpeed[2] = 0.00000f;
	}

	// Start/adjust animated movement (progresses over time).
	void startYawRotation(f32 unitsPerSecond)
	{
		this.rotateSpeed[0] = unitsPerSecond;
	}

	// Stop animated movement (progresses over time).
	void stopYawRotation()
	{
		this.rotateSpeed[0] = 0.0f;
	}

	// Start/adjust animated movement (progresses over time).
	void startPitchRotation(f32 unitsPerSecond)
	{
		this.rotateSpeed[1] = unitsPerSecond;
	}

	// Stop animated movement (progresses over time).
	void stopPitchRotation()
	{
		this.rotateSpeed[1] = 0.0f;
	}

	// Start/adjust animated movement (progresses over time).
	void startRollRotation(f32 radiansPerSecond)
	{
		rotateSpeed[2] = radiansPerSecond;
	}

	// Stop animated movement (progresses over time).
	void stopRollRotation()
	{
		rotateSpeed[2] = 0.0f;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// FPSCameraController
////////////////////////////////////////////////////////////////////////////////////////////////////

// First Person camera view input controller.
class FPSCameraController implements IKeyboardListener, IMouseListener
{
	Camera3D camera = null;
	CameraMover cameraMover = null;
	f32 rotateSpeed;
	f32 moveSpeed;
	f32 rollSpeed;
	bool invertMouseY;
	u32 keyForward;
	u32 keyBackward;
	u32 keyLeft;
	u32 keyRight;
	u32 keyRollCW;
	u32 keyRollCCW;
	bool enableMouseInput;
	bool enableKeyboardInput;
	bool inputEnabled;
	Rectangle2D<i32> inputArea();
	bool inInputArea;
	Vec2<i32> lastMousePos(-1000000, -1000000);
	
	// Create controoler. rotateSpeed in radians/sec. moveSpeed in world units/sec.
	void constructor(Camera3D camera, f32 rotateSpeed, f32 moveSpeed, f32 rollSpeed)
	{
		this.camera = camera;
		this.cameraMover = CameraMover(camera);

		this.rotateSpeed = rotateSpeed;
		this.moveSpeed   = moveSpeed;
		this.rollSpeed   = rollSpeed;

		this.invertMouseY = true;

		// keyboard mapping
		this.setMovementKeysToWASD();

		// for temporarily ignoring
		this.enableMouseInput = true;
		this.enableKeyboardInput = true;

		// allow input at all - used to temporarily disable control of the camera by user
		this.inputEnabled = true;

		// restricted rectangular canvas space area where we record and respond to input
		this.inputArea = Rectangle2D<i32>(0, 0, 8192, 8192);

		// if inputArea is used we track when mouse cursor is inside to disable/enable keyboard input
		this.inInputArea = true;

		cameraMover.movementOffset = camera.position;
	}

	// Enable or disable (ignore) all mouse/keyboard input.
	void setInputAllowed(bool allowInput)
	{
		this.inputEnabled = allowInput;
	}

	// Set a rectangular area to allow mouse messages to be used as input to the camera controller.
	void setInputArea(Rectangle2D<i32> inputArea)
	{
		this.inputArea = inputArea;
	}

	// Set Forward/Backward/Left/Right to arrow keys like a heretic.
	void setMovementKeysToArrows()
	{
		this.keyForward  = Keys:KEY_ARROW_UP;
		this.keyBackward = Keys:KEY_ARROW_DOWN;
		this.keyLeft     = Keys:KEY_ARROW_LEFT;
		this.keyRight    = Keys:KEY_ARROW_RIGHT;
		this.keyRollCW   = Keys:KEY_E;
		this.keyRollCCW  = Keys:KEY_Q;
	}

	// Set Forward/Backward/Left/Right to arrow keys like a uncivilized chump.
	void setMovementKeysToWASD()
	{
		this.keyForward  = Keys:KEY_W;
		this.keyBackward = Keys:KEY_S;
		this.keyLeft     = Keys:KEY_A;
		this.keyRight    = Keys:KEY_D;
		this.keyRollCW   = Keys:KEY_E;
		this.keyRollCCW  = Keys:KEY_Q;
	}

	// Speed is in radians/second.
	void setRotateSpeed(f32 speed)
	{
		this.rotateSpeed = speed;
	}

	// Forward/backwards, up/down, left/right. Speed is in world units/second.
	void setMoveSpeed(f32 speed)
	{ 
		this.moveSpeed = speed;
	}

	// Movement around roll vector. Speed is in radians/second.
	void setRollSpeed(f32 rollSpeed)
	{
		this.rollSpeed = rollSpeed;
	}

	// Invert mouse up/down movement.
	void setInvertMouseY(bool invertY)
	{ 
		this.invertMouseY = invertY; 
	}

	// Handle mouse input.
	void onMouseEvent(MouseEvent e)
	{
		if(lastMousePos[0] < -10000)
			lastMousePos.set(e.windowX, e.windowY); // first msg

		i32 deltaX = e.windowX - lastMousePos[0];
		i32 deltaY = e.windowY - lastMousePos[1];

		lastMousePos.set(e.windowX, e.windowY);

		// if mouse input allowed
		if(this.enableMouseInput == false)
			return;

		// any input allowed at all?
		if(this.inputEnabled == false)
			return;

		// restrict input to certain area?
		if(this.inputArea.getWidth() < 8192)
		{
			if(this.inputArea.contains(e.screenX, e.screenY) == false)
			{
				this.inInputArea = false;
				return; // we don't count input outside of this area
			}
		}
		this.inInputArea = true;

		camera.setYaw(camera.getYaw() + (deltaX * 0.01f));
		camera.setPitch(camera.getPitch() + (deltaY * 0.01f));
		camera.setRoll(0.0f);
	}

	// Handle key event.
	void onKeyEvent(KeyEvent e)
	{
		// if keyboard input allowed
		if(this.enableKeyboardInput == false)
			return;
		
		// any input allowed at all?
		if(this.inputEnabled == false)
			return;
		
		// restrict input to certain area?
		if(this.inputArea.getWidth() < 8192)
		{
			if(this.inInputArea == false)
				return; //we don't count input outside of this area
		}

		// Movement

		// forward/backward
		if(e.keyID == this.keyForward && e.isKeyDown())
			this.cameraMover.startMovingForward(this.moveSpeed);
		else if(e.keyID == this.keyBackward && e.isKeyDown())
			this.cameraMover.startMovingForward(-1 * this.moveSpeed);
		else if( (e.keyID == this.keyForward || e.keyID == this.keyBackward) && !e.isKeyDown())
			this.cameraMover.stopMovingForward();

		// sideways
		if(e.keyID == this.keyRight && e.isKeyDown())
			this.cameraMover.startMovingSideways(-1 * this.moveSpeed);
		else if(e.keyID == this.keyLeft && e.isKeyDown())
			this.cameraMover.startMovingSideways(this.moveSpeed);
		else if( (e.keyID == this.keyRight || e.keyID == this.keyLeft) && !e.isKeyDown())
			this.cameraMover.stopMovingSideways();
		
		// roll
		if(e.keyID == this.keyRollCW && e.isKeyDown())
			this.cameraMover.startRollRotation(this.rollSpeed);
		else if(e.keyID == this.keyRollCCW && e.isKeyDown())
			this.cameraMover.startRollRotation(-1 * this.rollSpeed);
		else if( (e.keyID == this.keyRollCW || e.keyID == this.keyRollCCW) && !e.isKeyDown())
			this.cameraMover.stopRollRotation();
	}

	// Call regularly to apply movement. time in milliseconds.
	void update(f64 time)
	{
		this.cameraMover.update(time);
		this.cameraMover.applyToCamera();
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// OrbitCameraController
////////////////////////////////////////////////////////////////////////////////////////////////////

//Construct a camera controller that orbits a single point (single point can be moved).
class OrbitCameraController implements IKeyboardListener, IMouseListener
{
	Vec3<f32> origin();
	bool rotateWithMouseMove;
	bool panWithMouseMove;
	bool invertMouseY;
	bool inputEnabled;
	Rectangle2D<i32> inputArea();
	bool inInputArea;
	Vec2<i32> middleDownPos();
	Vec2<i32> lastMousePos(-1000000, -1000000);
	bool ctrlKeyDown  = false;
	bool shiftKeyDown = false;
	Camera3D camera = null;

	// key bindings
	u32 mouseButtonForRotate; // MouseEvent:BUTTON_MIDDLE etc.

	// Construct to control passed-in camera.
	void constructor(Camera3D camera)
	{
		this.camera = camera;
		
		setDefaultKeyBindings();

		// settings
		this.invertMouseY = true;

		// compute
		this.origin = Vec3<f32>(); // to orbit

		// allow input at all - used to temporarily disable control of the camera by user
		this.inputEnabled = true;

		// restricted rectangular space area where we record and respond to input
		this.inputArea = Rectangle2D<i32>(0, 0, 8192, 8192);

		// if inputArea is used we track when mouse cursor is inside to disable/enable keyboard input
		this.inInputArea = true;

		// mouse key state
		this.rotateWithMouseMove = false; // we orbit up/down left/right when this is down
		this.panWithMouseMove    = false;

		// mouse position state
		this.middleDownPos = Vec2<i32>(-1, -1);
	}

	void setDefaultKeyBindings()
	{
		this.mouseButtonForRotate = MouseEvent:BUTTON_X0;
	}

	void setInputAllowed(bool allowInput)
	{
		this.inputEnabled = allowInput;
	}

	void setInputArea(Rectangle2D<i32> inputArea)
	{
		this.inputArea = inputArea;
	}

	// On IMouseListener events.
	void onMouseEvent(MouseEvent e)
	{
		// any input allowed at all?
		if(this.inputEnabled == false)
			return;
		
		// restrict input to certain area?
		if(this.inputArea.getWidth() < 8192)
		{
			if(this.inputArea.contains(e.screenX, e.screenY) == false)
			{
				this.inInputArea = false;

				// if we are currently doing any drag action, end it
				rotateWithMouseMove = false;
				panWithMouseMove    = false;

				return; //we don't count input outside of this area
			}
		}
		this.inInputArea = true;

		processMouseEvent(e);
	}

	// Apply mouse input.
	void processMouseEvent(MouseEvent e)
	{
		if(lastMousePos[0] < -10000)
			lastMousePos.set(e.windowX, e.windowY); // first msg

		i32 deltaX = e.windowX - lastMousePos[0];
		i32 deltaY = e.windowY - lastMousePos[1];

		lastMousePos.set(e.windowX, e.windowY);

		if(e.isButtonDown(mouseButtonForRotate) || shiftKeyDown == true)
		{
			this.rotateWithMouseMove = true;
			this.middleDownPos.set(e.screenX, e.screenY);
		}
		else if(e.isButtonDown(mouseButtonForRotate) == false && shiftKeyDown == false)
		{
			this.rotateWithMouseMove = false;
		}

		if(this.rotateWithMouseMove == true)
		{
			//adjust camera based on mouse movement delta
			Vec3<f32> eyePos = this.camera.position;

			//rotate both
			if(Math:compare(deltaX, 0.0f, 0.000f) == false || Math:compare(deltaY, 0.0f, 0.000f) == false)
			{
				// Keep the existing up vector of the camera to check for wrap around
				Vec3<f32> oldCameraUpVec = camera.getUpVector();
				Vec3<f32> oldCameraPos   = camera.position;
				Vec3<f32> oldCameraYPR   = camera.yawPitchRoll;

				//up/down
				f32 upDownRate = 0.01f;
				if(invertMouseY == false)
					upDownRate *= -1.0f;

				Vec3<f32> groundVector = this.camera.getGroundVector(this.camera.getForwardVector());
				Matrix4x4<f32> upDownMatrix();
				upDownMatrix.setAsRotationMatrix(groundVector, deltaY * upDownRate);

				// left/right
				Vec3<f32> upVector = Camera3D:Y_AXIS_POS; //this.camera.uxp;
				Matrix4x4<f32> leftRightMatrix();
				leftRightMatrix.setAsRotationMatrix(upVector, deltaX * -0.01f); // inverted x feels more natural

				// transform eye
				Matrix4x4<f32> transformEye(upDownMatrix);
				transformEye.mul(leftRightMatrix);

				Vec3<f32> newEyePos(eyePos);
				newEyePos -= this.origin; //always do rotation around 0,0,0
				transformEye.mul(newEyePos, newEyePos);

				// calculate new direction
				Vec3<f32> newDirection(0,0,0);
				newDirection -= newEyePos;
				newDirection.normalize();

				//translate to our non 0,0,0 origin
				newEyePos += this.origin;
					
				// set camera
				this.camera.setCameraLookAt(newEyePos, this.origin);
				
				// make sure we didn't wrap around
				if(oldCameraUpVec.dot(camera.getUpVector()) <= 0.0f)
				{
					// we flipped, ignore last input
					camera.setPosition(oldCameraPos);
					camera.setYawPitchRoll(oldCameraYPR);
				}
			}
		}
		
		if(this.panWithMouseMove == true)
		{
			// up/down
			Vec3<f32> groundVector = this.camera.getGroundVector(this.camera.getForwardVector());
			groundVector *= (deltaX * 0.05f);
			
			// left/right
			Vec3<f32> upVector(Camera3D:Y_AXIS_POS);
			upVector *= (deltaY * 0.05f);
			
			Vec3<f32> newCameraPos(this.camera.position);
			newCameraPos += groundVector;
			newCameraPos += upVector;
			
			Vec3<f32> newOrigin(this.origin);
			newOrigin += groundVector;
			newOrigin += upVector;
			this.origin.copy(newOrigin);
			
			// translate camera
			this.camera.setCameraLookAt(newCameraPos, newOrigin);
		}

		// zooming with mouse wheel
		f32 zoomFactor = 0.5f;
		if(ctrlKeyDown == true)
			zoomFactor *= 0.1f;

		if(e.eventID == MouseEvent:ID_WHEELUP) // zoom in
		{
			Vec3<f32> newCameraPos(this.camera.position);
			Vec3<f32> newPosToOrigin(newCameraPos);
			newPosToOrigin -= this.origin;
			newPosToOrigin.normalize();
			newPosToOrigin *= zoomFactor;
			newCameraPos -= newPosToOrigin;

			// make sure we haven't zoomed "beyond" the origin and flipped the camera
			if(camera.position.distanceTo(origin) > (zoomFactor + 0.010f))
			{
				this.camera.setCameraLookAt(newCameraPos, this.origin);
			}
		}
		else if(e.eventID == MouseEvent:ID_WHEELDOWN) //zoom out
		{
			Vec3<f32> newCameraPos(this.camera.position);
			Vec3<f32> newPosToOrigin(newCameraPos);
			newPosToOrigin -= this.origin;
			newPosToOrigin.normalize();
			newPosToOrigin *= zoomFactor;
			newCameraPos += newPosToOrigin;

			this.camera.setCameraLookAt(newCameraPos, this.origin);
		}
		
	}

	// On IKeyboardListener event.
	void onKeyEvent(KeyEvent e)
	{
		// any input allowed at all?
		if(this.inputEnabled == false)
			return;

		// restrict input to certain area?
		if(this.inputArea.getWidth() < 8192)
		{
			if(this.inInputArea == false)
				return; // we don't count input outside of this area
		}

		processKeyEvent(e);
	}

	// Apply key event.
	void processKeyEvent(KeyEvent e)
	{	
		if(e.isCTRLDown())
			ctrlKeyDown = true;
		else
			ctrlKeyDown = false;

		if(e.isShiftDown())
			shiftKeyDown = true;
		else
			shiftKeyDown = false;
		
		if(e.isShiftDown())
		{
			if(e.isShiftDown() == false)
			{
				rotateWithMouseMove = false;
			}
		}
		/*
		if(e.key == Keys:KEY_SPACE)
		{
			if(e.isKeyDown() && panWithMouseMove == false)
			{
				this.panWithMouseMove = true;
			}
			else if(panWithMouseMove == true && e.isKeyDown() == false)
			{
				this.panWithMouseMove = false;
			}
		}*/
	}
}