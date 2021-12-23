# What is Swift Growth?

This began as a Swift port of the wonderful project [biosim4](https://github.com/davidrmiller/biosim4) by David R. Miller. I've always been interested in neural networks, but had never really done anything with them, after watching David's [video](https://www.youtube.com/watch?v=N3tRFayqVtk) about his project, I was inspired to get a better understanding for how these worked. As an iOS developer, I'm most familiar with Swift, and thought porting the project would be a good way to learn.

I originally considered calling this `biosim4-swift` to make the connection more obvious, but as I work on it more I've realized I don't want this to be a 1-to-1 port, and would like to have it "grow" in it's own direction.

# Limitations

Currently this only works on MacOS, but given that it uses SpriteKit, it should be fairly easy to port to other Apple OSes. Performance is an active area of development, and eventually I might move to something more low level than SpriteKit (ex. Metal)

# Plans

Note that this is a side-project, so take everything in these plans with a grain of salt.

* Multiplatform (iOS, iPadOS, MacOS)
* Dynamic parameters (ex. change population, challenge etc. at runtime)
* Interacting with grid - drawing barriers and "safe areas" at runtime
* Interacting with individuals
    * View representation of neural net
	* Adjust lifespan (ex. make a specific individual immortal)
* Energy cost/reward (ex. movement takes X units of energy)
* Mutation rate based on proximity to radiation sources
* Heat sources
* Save/load parameters and populations
* Time controls (partially implemented, but currently no way to go back in time)