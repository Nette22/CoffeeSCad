define (require)->
  csg = require "modules/core/projects/csg/csg"
  CSGBase = csg.CSGBase
  CAGBase = csg.CAGBase
  Cube = csg.Cube
  Sphere = csg.Sphere
  Cylinder= csg.Cylinder
  Plane = csg.Plane
  hull = csg.hull
  Rectangle = csg.Rectangle
  Circle = csg.Circle
  
  
  describe "CSG: Basic , configurable geometry (3d) ", ->
    #CUBE
    it 'has a Cube geometry, default settings', ->
      cube = new Cube()
      expect(cube.polygons[0].vertices[0].pos).toEqual(new csg.Vector3D())
      
    it 'has a Cube geometry, object as arguments', ->
      cube = new Cube({size:100})
      expect(cube.polygons[0].vertices[0].pos).toEqual(new csg.Vector3D())
    
    ###No support for splats/simple arguments, might stay this way 
    it 'has a Cube geometry, simple arguments', ->
      cube = new Cube(null,100)
      expect(cube.polygons[0].vertices[0].pos).toEqual(new csg.Vector3D()) 
    ###
      
    it 'has a Cube geometry, center as boolean:true', ->
      cube = new Cube({size:100,center:true})
      expect(cube.polygons[0].vertices[0].pos).toEqual(new csg.Vector3D(-50,-50,-50))
    
    it 'has a Cube geometry, center as boolean:false', ->
      cube = new Cube({size:100,center:false})
      expect(cube.polygons[0].vertices[0].pos).toEqual(new csg.Vector3D())
    
    it 'has a Cube geometry, center as vector', ->
      cube = new Cube({size:100,center:[100,100,100]})
      expect(cube.polygons[0].vertices[0].pos).toEqual(new csg.Vector3D(100,100,100))
    
    it 'has a Cube geometry, size as vector', ->
      cube = new Cube({size:[100,5,50]})
      expect(cube.polygons[0].vertices[2].pos).toEqual(new csg.Vector3D(0,5,50))
    
    ###
    it 'has a Cube geometry, optional corner rounding , with rounding radius parameter, default rounding resolution', ->
      cube = new Cube({size:100,r:10})
      console.log cube
      expect(cube.polygons[0].vertices[2].pos).toEqual(new csg.Vector3D(0,5,50))
     
    it 'has a Cube geometry, optional corner rounding , with all rounding parameters', ->
      cube = new Cube({size:100,r:10,$fn:3})
      console.log cube
      expect(cube.polygons[0].vertices[2].pos).toEqual(new csg.Vector3D(0,5,50))
    ###  
    
    #SPHERE
    it 'has a Sphere geometry, size set by radius', ->
      sphere = new Sphere({r:50})
      expect(sphere.polygons[0].vertices[0].pos).toEqual(new csg.Vector3D(50,0,0))
    
    it 'has a Sphere geometry, size set by diameter', ->
      sphere = new Sphere({d:100})
      expect(sphere.polygons[0].vertices[0].pos).toEqual(new csg.Vector3D(50,0,0))
    
    it 'has a Sphere geometry, settable resolution', ->
      sphere = new Sphere({d:25,$fn:15})
      expect(sphere.polygons.length).toEqual(120)
    
    it 'has a Sphere geometry, center as boolean', ->
      sphere = new Sphere({d:25, center:true})
      expect(sphere.polygons[0].vertices[0].pos).toEqual(new csg.Vector3D(25,12.5,12.5))
    
    it 'has a Sphere geometry, center as vector', ->
      sphere = new Sphere({d:25, center:[100,100,100]})
      expect(sphere.polygons[0].vertices[0].pos).toEqual(new csg.Vector3D(112.5,100,100))
    
    #CYLINDER
    it 'has a Cylinder geometry, top and bottom radius set by radius parameter, default height', ->
      cylinder = new Cylinder({r:25,$fn:5})
      expect(cylinder.polygons[14].vertices[1].pos).toEqual(new csg.Vector3D(25,6.123031769111886e-15,1))

    it 'has a Cylinder geometry, top and bottom radius set by radius parameter, specified height', ->
      cylinder = new Cylinder({r:25, h:10,$fn:5})
      expect(cylinder.polygons[14].vertices[0].pos).toEqual(new csg.Vector3D(0,0,10))
    
    it 'has a Cylinder geometry, top and bottom radius set by diameter parameter', ->
      cylinder = new Cylinder({d:100,$fn:3})
      expect(cylinder.polygons[3].vertices[2].pos).toEqual(new csg.Vector3D(-25.00000000000002,43.30127018922192,0))
    
    it 'has a Cylinder geometry, with settable resolution', ->
      cylinder = new Cylinder({d:25,$fn:15})
      expect(cylinder.polygons.length).toEqual(45)
    
    it 'has a Sphere geometry, center as boolean', ->
      cylinder = new Cylinder({d:25, center:true, $fn:5})
      expect(cylinder.polygons[0].vertices[1].pos).toEqual(new csg.Vector3D(12.5,0,-0.5))
    
    it 'has a Sphere geometry, center as vector', ->
      cylinder = new Cylinder({d:25, center:[100,100,100], $fn:5})
      expect(cylinder.polygons[0].vertices[0].pos).toEqual(new csg.Vector3D(100,100,100))
      
  
  describe "CSG transforms", ->
    it 'can translate a csg object', ->
      cube = new Cube({size:100})
      cube.translate([100,0,0])
      expect(cube.polygons[0].vertices[0].pos.x).toBe(100)
      
    it 'can rotate a csg object', ->
      cube = new Cube({size:100})
      cube.rotate([45,45,45])
      expect(cube.polygons[0].vertices[1].pos.x).toBe(85.35533905932736)
    
    it 'can scale a csg object', ->
      cube = new Cube(size:100)
      cube.scale([100,100,100])
      expect(cube.polygons[0].vertices[1].pos.z).toBe(10000)
  
  describe "CSG boolean operations", ->
    beforeEach -> 
      @addMatchers 
        toBeEqualToObject: (expected) -> 
          _.isEqual @actual, expected
      
    it 'can do unions between two 3d shapes' , ->
      cube = new Cube(size:100)
      cube2 = new Cube(size:100,center:[90,90,0])
      cube.union(cube2)
      expect(cube.polygons.length).toBe(14)
    
    it 'can do unions between multiple 3d shapes' , ->
      cube = new Cube(size:100)
      cube2 = new Cube(size:100,center:[90,90,0])
      cube3 = new Cube(size:100,center:[90,90,-90])
      cube.union([cube2,cube3])
      expect(cube.polygons.length).toBe(16)
      
    it 'can do substractions between 3d shapes' , ->
      cube = new Cube(size:100)
      cube2 = new Cube(size:100,center:[90,90,0])
      cube.subtract(cube2)
      expect(cube.polygons.length).toBe(10)
    
    it 'can do intersection between 3d shapes' , ->
      cube = new Cube(size:100)
      cube2 = new Cube(size:100,center:[90,90,0])
      cube.intersect(cube2)
      expect(cube.polygons.length).toBe(6)
    
    it 'can slice a csg object by a plane' , ->
      cube = new Cube(size:100)
      cube2 = new Cube(size:100,center:[90,90,0])
      plane = Plane.fromNormalAndPoint([0, 0, 1], [0, 0, 25])
      cube.cutByPlane(plane)
      expect(cube.polygons.length).toBe(6)
      
  describe "CSG 2d shapes manipulation", ->
    beforeEach -> 
      @addMatchers 
        toBeEqualToObject: (expected) -> 
          _.isEqual @actual, expected
          
    it 'can do unions between 2d shapes' , ->
      circle = new Circle(r:25,center:[0,0],$fn:10)
      rectangle = new Rectangle(size:20).translate([100,0,0])
      circle.union(rectangle)
      expect(circle.sides.length).toBe(14)
    
    it 'can do subtraction between 2d shapes' , ->
      circle = new Circle(r:25,center:[0,0],$fn:10)
      rectangle = new Rectangle(size:20).translate([100,0,0])
      circle.subtract(rectangle)
      expect(circle.sides.length).toBe(10)
    
    it 'can do intersections between 2d shapes' , ->
      circle = new Circle(r:25,center:[0,0],$fn:10)
      rectangle = new Rectangle(size:25)
      circle.intersect(rectangle)
      expect(circle.sides.length).toBe(4)
    
    it 'can extrude 2d shapes', ->
      circle = new Circle(r:10,center:[0,0],$fn:10)
      cylinder = circle.extrude(offset: [0, 0, 100],twist:180,slices:20)
      expect(cylinder.polygons.length).toBe(402)
    
    it 'can generate a convex hull around 2d shapes', ->
      circle = new Circle(r:25,center:[0,0],$fn:10).translate([0,-25,0])
      rectangle = new Rectangle(size:20).translate([100,0,0])
      hulled = hull(circle,rectangle)
      expect(hulled.sides.length).toBe(9)
  
  describe "Base CSG class utilities", ->
    
    it 'clone csg objects' , ->
      cube = new Cube(size:100)
      cube2 = cube.clone()
      expect(cube2.polygons.length).toBe(cube.polygons.length)
  
   
  describe "Advances 2d & 3d shapes manipulation", ->
    
    it 'can generate valid (stl compatible) data out of 3d geometry' , ->
      cube = new Cube(size:100)
      cube2 = new Cube(size:100,center:[90,90,0])
      cube.subtract(cube2)
      stlCube = cube.fixTJunctions()
      expect(cube.polygons.length).toBe(10)
    
    
    it 'can generate valid (stl compatible) data out of tranformed 3d geometry' , -> 
      cube = new Cube(size:100)
      cube.rotate([25,10,15])
      stlCube = cube.fixTJunctions()
      expect(stlCube.polygons.length).toBe(6)
    
    it 'can generate valid (stl compatible) data out of "hulled", and extruded 2d geometry' , ->
      circle = new Circle({r:25,center:[10,50,20], $fn:6})
      circle2 = new Circle({r:25,center:[10,100,20], $fn:6})
      #rectangle = new Rectangle({size:10})
      hulled = hull(circle,circle2)
      hulledExtruded = hulled.extrude({offset:[0,0,1],steps:1,twist:0})
      hulledExtruded.fixTJunctions()
      expect(hulledExtruded.polygons.length).toBe(182)
   
   ###Can get slow, hence why it is commented
   describe "Speed and limitations", ->
     it 'does not cause recursion/stack overflow error with more detailed geometry' , ->
       sphere = new Sphere({r:100,$fn:100})
       sphere2 = new Sphere({r:100,$fn:100})
       
       expect(sphere.union(sphere2)).not.toThrow(new RangeError())
   ###  
     
    
    
    

