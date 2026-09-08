# Tux Ride 🐧👑 — Emperor Penguin Mount Design Specification

## 1. Overview & Objectives

Add a feature to **Tux Script** under the **Fun** category: **Tux Ride**.
Spawns a massive, high-detail procedural 3D **Emperor Penguin** companion that the player can mount and ride across the map.

### Key Highlights
- **Stately Emperor Aesthetic:** Realistic coloration (black feathers, silky white breast, vibrant gold/yellow ear & neck gradients, custom leather saddle with reins and golden stirrups).
- **Dual Interactive Mounting:** Modern `ProximityPrompt` ("Mount Emperor Tux [E] / Tap") plus legacy `ClickDetector` fallback.
- **Dynamic Physics & Controls:** Full WASD / Mobile joystick steering with responsive turn-banking, ground raycasting, slope alignment, and configurable speeds.
- **Synchronized Dual Animations:**
  - *Emperor Penguin:* Heavy waddle walk, high-speed ice belly-slide with snow/frost particle rooster tails, jump flaps, breathing idle.
  - *Player Rider:* Procedural riding pose holding the reins, dynamic torso leaning into sharp turns, and tucking forward aerodynamically during belly-sliding.
- **Menu Integration:** Toggle and speed slider in the "Fun" column, clean unload handling, auto-remount safety.

---

## 2. 3D Model Architecture (Emperor Penguin & Saddle)

The model is procedurally constructed client-side and parented directly to `Workspace` for optimal rendering performance, zero replication lag, and full collision-exempt smoothness.

### 2.1 Scale & Proportions
- Height: ~4.8 studs (2.6x larger than the companion chibi pet).
- Width/Depth: Proportionally weighted to naturally seat an R6 or R15 character without clipping.

### 2.2 Anatomical Components
1. **Primary Root (`MountRoot`):** Invisible, massless root part handling positioning, raycasting, and orientation.
2. **Body & Chest (`Body`, `Belly`):**
   - Body: Deep black matte (`Color3.fromRGB(18, 20, 28)`), smooth sphere mesh.
   - Belly: Silky white chest plate (`Color3.fromRGB(248, 250, 255)`), contoured forward.
3. **Emperor Markings (`NeckGoldLeft`, `NeckGoldRight`, `ChestYellow`):**
   - Golden-orange auricular patches (`Color3.fromRGB(255, 175, 45)` and `Color3.fromRGB(255, 205, 75)`) sweeping along the sides of the neck into the upper breast.
4. **Head & Beak (`Head`, `BeakUpper`, `BeakLower`, `BeakStripe`):**
   - Sculpted head with expressive dark eyes and white specular rings.
   - Slender Emperor beak with a distinctive coral/pink-orange mandibular stripe.
5. **Wings / Flippers (`LeftFlipper`, `RightFlipper`):**
   - Elongated hydrodynamic flippers mounted on pivot CFrames for flapping and aerodynamic tucking.
6. **Feet (`LeftFoot`, `RightFoot`):**
   - Webbed orange/black Emperor claws (`Color3.fromRGB(45, 40, 35)` & `Color3.fromRGB(240, 140, 30)`).
7. **Tail (`Tail`):** Short stiff wedge acting as a rudder.

### 2.3 Riding Gear (Tack & Saddle)
1. **Leather Saddle (`SaddleBase`, `SaddlePummel`, `SaddleCantle`):**
   - Rich dark-brown leather (`Color3.fromRGB(55, 35, 25)`, `Enum.Material.Leather`).
   - Contoured to the penguin's upper back with a supportive rear cantle.
2. **Golden Stirrups & Buckles:**
   - Polished gold accents (`Color3.fromRGB(235, 185, 55)`, `Enum.Material.Metal`).
3. **Reins (`ReinLeft`, `ReinRight`):**
   - Flexible bridle straps extending from the beak collar to the rider's grip positions.
4. **VehicleSeat (`RideSeat`):**
   - Invisible `VehicleSeat` (or custom responsive `Seat`) anchored within the saddle at `Vector3.new(0, 1.25, 0.2)` relative to `MountRoot`.
   - `MaxSpeed = 0` (movement handled by our custom physics engine to guarantee high performance, anti-cheat resistance, and smooth banking).

---

## 3. Mounting & Interaction System

### 3.1 Mount Trigger
- **ProximityPrompt:**
  - ObjectText: `"Emperor Tux"`
  - ActionText: `"Ride [E]"`
  - HoldDuration: `0` (Instant, snappy response)
  - MaxActivationDistance: `14` studs
  - RequiresLineOfSight: `false`
- **ClickDetector:**
  - MaxActivationDistance: `20` studs for quick tap/click on mobile or PC.

### 3.2 Mounting Flow
1. Player presses [E] or clicks the Emperor.
2. Character humanoid is seated into `RideSeat` (`RideSeat:Sit(Humanoid)`).
3. Camera automatically offsets smoothly to a comfortable third-person riding view.
4. An overhead status badge shows: `👑 Emperor Tux • LO's Mount`.

### 3.3 Dismounting Flow
- Player presses [Space] (Jump key) or clicks "Dismount" prompt.
- Humanoid `Jump` state triggers unseating.
- Character is safely positioned to the left side of the penguin with zero fling or velocity spike.

---

## 4. Physics & Movement Engine

### 4.1 Input Handling
- Reads `UserInputService` or `VehicleSeat.Throttle` / `VehicleSeat.Steer` (PC WASD, Arrow keys, Mobile Touch D-Pad / Thumbstick).
- `W / S`: Forward / Reverse throttle.
- `A / D`: Steering angular velocity.
- `LeftShift`: Turbo Belly-Slide toggle/hold.
- `Space`: Jump / Glide.

### 4.2 Ground Raycasting & Slope Alignment
- Downward raycast from `MountRoot.Position + Vector3.new(0, 3, 0)` down `15` studs.
- Ignores player character and penguin parts (`RaycastParams`).
- Smoothly snaps Y position to terrain/floor height with a dampening spring.
- Surface normal alignment: Tux leans into hills and stairs naturally using `CFrame.fromMatrix`.

### 4.3 Movement States & Speed
- **Walking / Trot:** Speeds 16 to 45 studs/sec.
- **Ice Belly-Slide (Sprint / High Speed):** Speeds 46 to 120+ studs/sec (governed by "Ride Speed" slider in GUI).
- **Braking & Inertia:** Smooth friction deceleration so stops feel weighty and natural.

---

## 5. Dual Animation Engine

### 5.1 Emperor Penguin Animations
1. **Waddle-Walk (Throttle active, Speed <= 45):**
   - Lateral roll: ±12 degrees oscillation timed with step cycle.
   - Alternating foot shuffles with vertical lift.
   - Dynamic flipper sync: wings flap slightly outward to balance waddling weight.
2. **Turbo Belly-Slide (Speed > 45 or Shift held):**
   - Tux pivots forward 76 degrees onto his belly.
   - Flippers tuck backward aerodynamically.
   - Feet extend straight back.
   - Particle emitter sprays high-density ice and snow flakes from under the belly.
3. **Idle State:**
   - Subtle vertical breathing heave (sine wave on torso).
   - Head glances left and right curiously.
   - Flippers relax along the flanks.
4. **Jump / Airborne:**
   - Flippers spread wide for gliding.
   - Feet tuck upward.

### 5.2 Rider Animations (Procedural Kinematics)
1. **Seat Lock:** Character is seated firmly; torso tilt matches penguin pitch/roll.
2. **Rein Grip:**
   - If R15: Procedural rotation on `RightShoulder` and `LeftShoulder` extending arms forward towards the saddle reins.
   - If R6: Arms elevated 40 degrees forward in riding posture.
3. **Turn Banking:** Rider's torso leans in the direction of the turn (`Steer` input) by up to 15 degrees.
4. **Slide Tuck:** When entering Belly-Slide mode, rider leans low over Tux's neck (jockey / speed-skater tuck) to reduce drag.

---

## 6. Menu Integration & GUI Controls

### Location: `Fun` Column in Tux Script GUI
1. **Toggle: `Tux Ride 👑`**
   - ON: Spawns Emperor Tux adjacent to the player, enables prompt, emits sparkling snow puff.
   - OFF: Safely dismounts player, cleans up all instances and loops, unloads gracefully.
2. **Slider: `Ride Speed`**
   - Range: `30` to `150` studs/s (Default: `75`).
   - Real-time adjustment applies immediately to movement physics.

---

## 7. Edge Cases & Resilience

- **Character Death / Reset:** Listener on `CharacterAdded` cleans up old mount and automatically respawns Tux Ride if `State.TuxRide` is enabled.
- **Falling into Void:** If Y position < -100, dismounts and repositions to a safe spawn.
- **Anti-Fling:** Mount parts have `CanCollide = false` and `Massless = true` to avoid colliding with other players or flinging the map.
- **Full Script Unload:** Registers all connections and instances into `Connections` and `InstancesToClean` tables for clean termination.

---

## 8. Verification & Testing Checklist

- [ ] Spawn toggle activates and creates Emperor Tux with correct scale and colors.
- [ ] Golden neck patches and saddle details render cleanly.
- [ ] ProximityPrompt and ClickDetector both mount the player.
- [ ] WASD / Mobile joystick steers smoothly with acceleration and braking.
- [ ] Low-speed waddle animation rocks side to side with wing flaps.
- [ ] High-speed belly-slide tilts body, tucks wings, and emits snow particles.
- [ ] Rider leans into turns and crouches on belly-slide.
- [ ] Jump key dismounts cleanly without glitches.
- [ ] Slider dynamically changes top speed.
- [ ] Toggle OFF cleans up all models, connections, and particles.
