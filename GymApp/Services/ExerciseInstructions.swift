import Foundation

enum ExerciseInstructions {
    struct Info: Sendable {
        let description: String
        let primaryMuscles: [String]
        let steps: [String]
    }

    static func info(for exerciseName: String) -> Info? {
        library[exerciseName]
    }

    static let library: [String: Info] = [
        // MARK: - Chest

        "Barbell Bench Press": Info(
            description: "A compound upper-body pressing movement and one of the most effective exercises for building chest strength and size.",
            primaryMuscles: ["Chest", "Triceps", "Front Delts"],
            steps: [
                "Lie flat on a bench with your feet firmly on the floor.",
                "Grip the bar slightly wider than shoulder-width apart.",
                "Unrack the bar and lower it to your mid-chest with control.",
                "Press the bar back up to full arm extension.",
                "Keep your shoulder blades retracted and back slightly arched throughout."
            ]
        ),
        "Incline Barbell Bench Press": Info(
            description: "An incline variation of the bench press that emphasizes the upper chest and front deltoids.",
            primaryMuscles: ["Upper Chest", "Triceps", "Front Delts"],
            steps: [
                "Set the bench to a 30-45 degree incline.",
                "Grip the bar slightly wider than shoulder-width.",
                "Unrack and lower the bar to your upper chest.",
                "Press the bar back up to full extension.",
                "Keep your back pressed into the bench and feet flat on the floor."
            ]
        ),
        "Dumbbell Bench Press": Info(
            description: "A dumbbell variation of the bench press that allows a greater range of motion and helps address muscle imbalances.",
            primaryMuscles: ["Chest", "Triceps", "Front Delts"],
            steps: [
                "Lie flat on a bench holding a dumbbell in each hand at chest level.",
                "Press the dumbbells up until your arms are fully extended.",
                "Lower the dumbbells slowly to the sides of your chest.",
                "Keep your wrists stacked over your elbows throughout the movement."
            ]
        ),
        "Incline Dumbbell Press": Info(
            description: "An incline pressing movement with dumbbells that targets the upper chest while allowing independent arm movement.",
            primaryMuscles: ["Upper Chest", "Triceps", "Front Delts"],
            steps: [
                "Set the bench to a 30-45 degree incline.",
                "Hold a dumbbell in each hand at shoulder level.",
                "Press the dumbbells up and slightly inward until arms are extended.",
                "Lower with control back to the starting position."
            ]
        ),
        "Dumbbell Fly": Info(
            description: "An isolation exercise that stretches and contracts the chest muscles through a wide arc of motion.",
            primaryMuscles: ["Chest", "Front Delts"],
            steps: [
                "Lie flat on a bench with a dumbbell in each hand, arms extended above your chest.",
                "With a slight bend in your elbows, lower the dumbbells out to the sides in a wide arc.",
                "Lower until you feel a stretch in your chest.",
                "Squeeze your chest to bring the dumbbells back together above you."
            ]
        ),
        "Cable Fly": Info(
            description: "A cable-based chest isolation exercise that maintains constant tension throughout the entire range of motion.",
            primaryMuscles: ["Chest", "Front Delts"],
            steps: [
                "Set both cable pulleys to shoulder height.",
                "Grab a handle in each hand and step forward into a staggered stance.",
                "With a slight bend in your elbows, bring your hands together in front of your chest.",
                "Slowly return to the starting position with arms wide."
            ]
        ),
        "Push-Up": Info(
            description: "A fundamental bodyweight exercise that builds chest, shoulder, and tricep strength with no equipment needed.",
            primaryMuscles: ["Chest", "Triceps", "Front Delts"],
            steps: [
                "Start in a plank position with hands slightly wider than shoulder-width.",
                "Keep your body in a straight line from head to heels.",
                "Lower your chest toward the floor by bending your elbows.",
                "Push back up to the starting position.",
                "Engage your core throughout the movement."
            ]
        ),
        "Chest Dip": Info(
            description: "A bodyweight compound exercise performed on parallel bars that heavily targets the lower chest and triceps.",
            primaryMuscles: ["Lower Chest", "Triceps", "Front Delts"],
            steps: [
                "Grip the parallel bars and lift yourself to the starting position with arms extended.",
                "Lean your torso slightly forward.",
                "Lower your body by bending your elbows until you feel a stretch in your chest.",
                "Press back up to full arm extension.",
                "Keep the forward lean to emphasize the chest over triceps."
            ]
        ),

        // MARK: - Back

        "Barbell Row": Info(
            description: "A compound pulling movement that builds thickness across the entire back, particularly the lats and rhomboids.",
            primaryMuscles: ["Lats", "Rhomboids", "Rear Delts", "Biceps"],
            steps: [
                "Stand with feet shoulder-width apart, holding a barbell with an overhand grip.",
                "Hinge at the hips until your torso is roughly 45 degrees to the floor.",
                "Pull the bar toward your lower chest, squeezing your shoulder blades together.",
                "Lower the bar with control back to the starting position.",
                "Keep your core tight and back flat throughout."
            ]
        ),
        "Dumbbell Row": Info(
            description: "A unilateral back exercise that allows you to focus on each side independently, great for fixing imbalances.",
            primaryMuscles: ["Lats", "Rhomboids", "Rear Delts", "Biceps"],
            steps: [
                "Place one knee and hand on a bench for support.",
                "Hold a dumbbell in the opposite hand with your arm hanging straight down.",
                "Pull the dumbbell up toward your hip, keeping your elbow close to your body.",
                "Lower the dumbbell with control.",
                "Keep your back flat and parallel to the floor."
            ]
        ),
        "Pull-Up": Info(
            description: "A challenging bodyweight exercise that builds lat width and overall upper body pulling strength.",
            primaryMuscles: ["Lats", "Biceps", "Rear Delts", "Core"],
            steps: [
                "Hang from a pull-up bar with an overhand grip, hands wider than shoulder-width.",
                "Engage your lats and pull yourself up until your chin clears the bar.",
                "Lower yourself with control back to a full hang.",
                "Avoid swinging or using momentum."
            ]
        ),
        "Chin-Up": Info(
            description: "An underhand-grip pull-up variation that places more emphasis on the biceps while still working the back.",
            primaryMuscles: ["Lats", "Biceps", "Rear Delts"],
            steps: [
                "Hang from a pull-up bar with an underhand (supinated) grip, hands shoulder-width apart.",
                "Pull yourself up until your chin clears the bar.",
                "Lower yourself with control to a full hang.",
                "Focus on driving your elbows down and back."
            ]
        ),
        "Lat Pulldown": Info(
            description: "A machine-based exercise that mimics the pull-up motion and is excellent for building lat width.",
            primaryMuscles: ["Lats", "Biceps", "Rear Delts"],
            steps: [
                "Sit at a lat pulldown machine and secure your thighs under the pads.",
                "Grip the bar wider than shoulder-width with an overhand grip.",
                "Pull the bar down to your upper chest, squeezing your lats.",
                "Slowly return the bar to the starting position with control."
            ]
        ),
        "Seated Cable Row": Info(
            description: "A seated pulling exercise using a cable machine that targets the middle back and helps improve posture.",
            primaryMuscles: ["Lats", "Rhomboids", "Rear Delts", "Biceps"],
            steps: [
                "Sit at a cable row station with your feet on the footplate and knees slightly bent.",
                "Grab the handle with both hands and sit upright.",
                "Pull the handle toward your abdomen, squeezing your shoulder blades together.",
                "Slowly extend your arms back to the starting position."
            ]
        ),
        "T-Bar Row": Info(
            description: "A heavy compound row variation that allows you to load significant weight for building back thickness.",
            primaryMuscles: ["Lats", "Rhomboids", "Rear Delts", "Biceps"],
            steps: [
                "Straddle the T-bar or landmine setup with feet shoulder-width apart.",
                "Hinge at the hips and grip the handle with both hands.",
                "Pull the weight toward your chest, squeezing your back at the top.",
                "Lower the weight with control.",
                "Keep your back flat and core braced throughout."
            ]
        ),
        "Deadlift": Info(
            description: "A foundational full-body compound lift that builds posterior chain strength, particularly the back, glutes, and hamstrings.",
            primaryMuscles: ["Back", "Glutes", "Hamstrings", "Core"],
            steps: [
                "Stand with feet hip-width apart, barbell over mid-foot.",
                "Hinge at the hips and grip the bar just outside your knees.",
                "Brace your core, flatten your back, and drive through your feet to stand up.",
                "Keep the bar close to your body throughout the lift.",
                "Lower the bar by hinging at the hips first, then bending the knees."
            ]
        ),

        // MARK: - Shoulders

        "Overhead Press": Info(
            description: "A fundamental compound pressing movement that builds strong, well-rounded shoulders and upper body pressing power.",
            primaryMuscles: ["Front Delts", "Side Delts", "Triceps"],
            steps: [
                "Stand with feet shoulder-width apart, holding a barbell at shoulder height.",
                "Brace your core and press the bar overhead until your arms are fully extended.",
                "Lower the bar back to shoulder height with control.",
                "Keep your rib cage down and avoid excessive back arching."
            ]
        ),
        "Dumbbell Shoulder Press": Info(
            description: "A seated or standing dumbbell press that allows each arm to move independently for balanced shoulder development.",
            primaryMuscles: ["Front Delts", "Side Delts", "Triceps"],
            steps: [
                "Hold a dumbbell in each hand at shoulder height with palms facing forward.",
                "Press the dumbbells overhead until your arms are fully extended.",
                "Lower the dumbbells back to shoulder height.",
                "Keep your core engaged and avoid arching your back."
            ]
        ),
        "Lateral Raise": Info(
            description: "An isolation exercise that targets the side deltoids for wider-looking shoulders.",
            primaryMuscles: ["Side Delts"],
            steps: [
                "Stand with a dumbbell in each hand at your sides.",
                "With a slight bend in your elbows, raise your arms out to the sides until parallel with the floor.",
                "Pause briefly at the top.",
                "Lower the weights slowly back to your sides."
            ]
        ),
        "Front Raise": Info(
            description: "An isolation exercise that targets the front deltoids, complementing pressing movements.",
            primaryMuscles: ["Front Delts"],
            steps: [
                "Stand holding dumbbells in front of your thighs with palms facing your body.",
                "Raise one or both arms straight in front of you to shoulder height.",
                "Pause briefly at the top.",
                "Lower with control back to the starting position."
            ]
        ),
        "Face Pull": Info(
            description: "A cable exercise that targets the rear deltoids and rotator cuff, essential for shoulder health and posture.",
            primaryMuscles: ["Rear Delts", "Rotator Cuff", "Upper Traps"],
            steps: [
                "Set a cable pulley to upper chest or face height with a rope attachment.",
                "Grip the rope with both hands and step back to create tension.",
                "Pull the rope toward your face, separating your hands as you pull.",
                "Squeeze your rear delts and hold briefly.",
                "Return to the starting position with control."
            ]
        ),
        "Reverse Fly": Info(
            description: "An isolation exercise for the rear deltoids that helps balance shoulder development and improve posture.",
            primaryMuscles: ["Rear Delts", "Rhomboids"],
            steps: [
                "Bend forward at the hips holding a dumbbell in each hand.",
                "With a slight bend in your elbows, raise your arms out to the sides.",
                "Squeeze your shoulder blades together at the top.",
                "Lower the weights slowly back to the starting position."
            ]
        ),
        "Arnold Press": Info(
            description: "A dumbbell press variation that rotates through a larger range of motion, hitting all three heads of the deltoid.",
            primaryMuscles: ["Front Delts", "Side Delts", "Triceps"],
            steps: [
                "Hold dumbbells at shoulder height with palms facing you.",
                "As you press upward, rotate your palms to face forward.",
                "Fully extend your arms overhead.",
                "Reverse the motion as you lower the dumbbells back down."
            ]
        ),

        // MARK: - Arms

        "Barbell Curl": Info(
            description: "The classic bicep exercise that allows you to use heavier loads for maximum bicep strength and size.",
            primaryMuscles: ["Biceps", "Forearms"],
            steps: [
                "Stand with feet shoulder-width apart, holding a barbell with an underhand grip.",
                "Curl the bar up toward your shoulders, keeping your upper arms stationary.",
                "Squeeze your biceps at the top of the movement.",
                "Lower the bar slowly back to the starting position."
            ]
        ),
        "Dumbbell Curl": Info(
            description: "A versatile bicep exercise using dumbbells that allows for various grip positions and independent arm training.",
            primaryMuscles: ["Biceps", "Forearms"],
            steps: [
                "Stand holding a dumbbell in each hand at your sides with palms facing forward.",
                "Curl the dumbbells up toward your shoulders.",
                "Squeeze your biceps at the top.",
                "Lower the weights with control."
            ]
        ),
        "Hammer Curl": Info(
            description: "A curl variation with a neutral grip that targets the brachialis and brachioradialis for thicker arms.",
            primaryMuscles: ["Biceps", "Brachialis", "Forearms"],
            steps: [
                "Stand holding dumbbells at your sides with palms facing each other (neutral grip).",
                "Curl the dumbbells up toward your shoulders while maintaining the neutral grip.",
                "Squeeze at the top.",
                "Lower with control back to the starting position."
            ]
        ),
        "Preacher Curl": Info(
            description: "An isolation bicep exercise performed on a preacher bench that eliminates momentum and targets the lower bicep.",
            primaryMuscles: ["Biceps"],
            steps: [
                "Sit at a preacher bench with your upper arms resting on the pad.",
                "Hold an EZ-bar or dumbbells with an underhand grip.",
                "Curl the weight up toward your shoulders.",
                "Lower the weight slowly, fully extending your arms at the bottom."
            ]
        ),
        "Tricep Pushdown": Info(
            description: "A cable-based isolation exercise that effectively targets all three heads of the triceps.",
            primaryMuscles: ["Triceps"],
            steps: [
                "Stand at a cable machine with a straight bar or rope attachment at the top.",
                "Grip the attachment with both hands and keep your elbows tucked at your sides.",
                "Push the weight down until your arms are fully extended.",
                "Slowly return to the starting position, keeping your elbows stationary."
            ]
        ),
        "Overhead Tricep Extension": Info(
            description: "A tricep exercise that emphasizes the long head of the triceps through an overhead stretching motion.",
            primaryMuscles: ["Triceps"],
            steps: [
                "Hold a dumbbell or EZ-bar overhead with both hands, arms fully extended.",
                "Lower the weight behind your head by bending at the elbows.",
                "Keep your upper arms close to your ears and stationary.",
                "Extend your arms back to the starting position."
            ]
        ),
        "Skull Crusher": Info(
            description: "A lying tricep extension that provides an intense stretch and contraction for building tricep mass.",
            primaryMuscles: ["Triceps"],
            steps: [
                "Lie on a bench holding an EZ-bar or dumbbells with arms extended above your chest.",
                "Lower the weight toward your forehead by bending at the elbows.",
                "Keep your upper arms perpendicular to the floor.",
                "Extend your arms back to the starting position."
            ]
        ),
        "Close-Grip Bench Press": Info(
            description: "A bench press variation with a narrow grip that shifts emphasis from the chest to the triceps.",
            primaryMuscles: ["Triceps", "Chest", "Front Delts"],
            steps: [
                "Lie on a bench and grip the barbell with hands shoulder-width apart or slightly narrower.",
                "Unrack the bar and lower it to your lower chest, keeping elbows close to your body.",
                "Press the bar back up to full extension.",
                "Focus on driving through your triceps."
            ]
        ),

        // MARK: - Legs

        "Barbell Squat": Info(
            description: "The king of lower body exercises, building strength and mass in the quads, glutes, and entire posterior chain.",
            primaryMuscles: ["Quads", "Glutes", "Hamstrings", "Core"],
            steps: [
                "Position the bar on your upper traps and step back from the rack.",
                "Stand with feet shoulder-width apart, toes slightly turned out.",
                "Brace your core and squat down by pushing your hips back and bending your knees.",
                "Descend until your thighs are at least parallel to the floor.",
                "Drive through your feet to stand back up."
            ]
        ),
        "Front Squat": Info(
            description: "A squat variation with the bar in front that emphasizes the quads and requires more core stability.",
            primaryMuscles: ["Quads", "Glutes", "Core"],
            steps: [
                "Rest the bar on the front of your shoulders with elbows high (clean grip or cross-arm grip).",
                "Stand with feet shoulder-width apart.",
                "Squat down, keeping your torso as upright as possible.",
                "Descend until your thighs are parallel to the floor.",
                "Drive through your feet to return to standing."
            ]
        ),
        "Leg Press": Info(
            description: "A machine-based compound exercise that allows you to safely load heavy weight for quad and glute development.",
            primaryMuscles: ["Quads", "Glutes", "Hamstrings"],
            steps: [
                "Sit in the leg press machine with your back flat against the pad.",
                "Place your feet shoulder-width apart on the platform.",
                "Release the safety catches and lower the weight by bending your knees.",
                "Lower until your knees reach about 90 degrees.",
                "Press the platform back up without locking your knees."
            ]
        ),
        "Romanian Deadlift": Info(
            description: "A hip-hinge movement that primarily targets the hamstrings and glutes with a focus on the eccentric stretch.",
            primaryMuscles: ["Hamstrings", "Glutes", "Lower Back"],
            steps: [
                "Stand holding a barbell at hip level with an overhand grip.",
                "With a slight bend in your knees, hinge at the hips and lower the bar along your legs.",
                "Lower until you feel a deep stretch in your hamstrings.",
                "Drive your hips forward to return to standing.",
                "Keep the bar close to your body and your back flat throughout."
            ]
        ),
        "Leg Curl": Info(
            description: "An isolation exercise that targets the hamstrings through knee flexion, typically performed on a machine.",
            primaryMuscles: ["Hamstrings"],
            steps: [
                "Lie face down on a leg curl machine with the pad against your lower calves.",
                "Curl your heels toward your glutes by bending your knees.",
                "Squeeze your hamstrings at the top of the movement.",
                "Lower the weight slowly back to the starting position."
            ]
        ),
        "Leg Extension": Info(
            description: "An isolation exercise that targets the quadriceps through knee extension, performed on a machine.",
            primaryMuscles: ["Quads"],
            steps: [
                "Sit on a leg extension machine with the pad resting on your shins just above your ankles.",
                "Extend your legs until they are straight.",
                "Squeeze your quads at the top.",
                "Lower the weight slowly back to the starting position."
            ]
        ),
        "Bulgarian Split Squat": Info(
            description: "A challenging unilateral leg exercise that builds single-leg strength, balance, and addresses muscle imbalances.",
            primaryMuscles: ["Quads", "Glutes", "Hamstrings"],
            steps: [
                "Stand a couple of feet in front of a bench with one foot resting on it behind you.",
                "Hold dumbbells at your sides or a barbell on your back.",
                "Lower your back knee toward the floor by bending your front leg.",
                "Descend until your front thigh is roughly parallel to the floor.",
                "Drive through your front foot to return to standing."
            ]
        ),
        "Calf Raise": Info(
            description: "An isolation exercise for the calf muscles, performed standing or seated to build lower leg size and strength.",
            primaryMuscles: ["Calves"],
            steps: [
                "Stand on the edge of a step or calf raise platform with your heels hanging off.",
                "Rise up onto your toes as high as possible.",
                "Pause briefly at the top and squeeze your calves.",
                "Lower your heels below the platform for a full stretch.",
                "You can hold dumbbells or use a machine for added resistance."
            ]
        ),
        "Hip Thrust": Info(
            description: "The premier glute-building exercise that maximizes hip extension force for stronger, bigger glutes.",
            primaryMuscles: ["Glutes", "Hamstrings"],
            steps: [
                "Sit on the floor with your upper back against a bench and a barbell across your hips.",
                "Plant your feet flat on the floor about shoulder-width apart.",
                "Drive through your heels to lift your hips until your body forms a straight line from shoulders to knees.",
                "Squeeze your glutes hard at the top.",
                "Lower your hips back down with control."
            ]
        ),
        "Lunge": Info(
            description: "A functional unilateral exercise that builds leg strength, balance, and coordination.",
            primaryMuscles: ["Quads", "Glutes", "Hamstrings"],
            steps: [
                "Stand tall with feet hip-width apart, holding dumbbells at your sides.",
                "Step forward with one leg and lower your body until both knees are at 90 degrees.",
                "Keep your front knee aligned over your ankle.",
                "Push through your front foot to return to the starting position.",
                "Alternate legs or complete all reps on one side first."
            ]
        ),

        // MARK: - Core

        "Plank": Info(
            description: "A foundational isometric core exercise that builds stability and endurance across the entire midsection.",
            primaryMuscles: ["Core", "Shoulders", "Glutes"],
            steps: [
                "Start in a push-up position, then lower to your forearms.",
                "Keep your body in a straight line from head to heels.",
                "Engage your core by pulling your belly button toward your spine.",
                "Hold the position for the desired duration.",
                "Avoid letting your hips sag or pike up."
            ]
        ),
        "Hanging Leg Raise": Info(
            description: "An advanced core exercise that targets the lower abs through hip flexion while hanging from a bar.",
            primaryMuscles: ["Lower Abs", "Hip Flexors"],
            steps: [
                "Hang from a pull-up bar with arms fully extended.",
                "Keeping your legs straight (or slightly bent), raise them until they are parallel to the floor or higher.",
                "Lower your legs slowly back to the starting position.",
                "Avoid swinging or using momentum."
            ]
        ),
        "Cable Crunch": Info(
            description: "A weighted core exercise using a cable machine that allows progressive overload for ab development.",
            primaryMuscles: ["Abs"],
            steps: [
                "Kneel in front of a cable machine with a rope attachment at the top.",
                "Hold the rope behind your head.",
                "Crunch down by flexing your spine, bringing your elbows toward your knees.",
                "Squeeze your abs at the bottom.",
                "Return to the starting position with control."
            ]
        ),
        "Ab Wheel Rollout": Info(
            description: "A challenging anti-extension core exercise that builds serious core strength and stability.",
            primaryMuscles: ["Abs", "Core", "Shoulders"],
            steps: [
                "Kneel on the floor holding an ab wheel with both hands.",
                "Roll the wheel forward by extending your body, keeping your arms straight.",
                "Extend as far as you can while maintaining a flat back.",
                "Use your core to pull yourself back to the kneeling position.",
                "Avoid letting your lower back sag at any point."
            ]
        ),
        "Russian Twist": Info(
            description: "A rotational core exercise that targets the obliques and improves trunk rotation strength.",
            primaryMuscles: ["Obliques", "Abs"],
            steps: [
                "Sit on the floor with your knees bent and feet slightly elevated.",
                "Lean back slightly to engage your core.",
                "Hold a weight or medicine ball with both hands at chest level.",
                "Rotate your torso to one side, then to the other.",
                "Keep your core tight and movement controlled throughout."
            ]
        ),

        // MARK: - Cardio

        "Running": Info(
            description: "A high-impact cardiovascular exercise that builds endurance, burns calories, and improves heart health.",
            primaryMuscles: ["Quads", "Hamstrings", "Calves", "Core"],
            steps: [
                "Start with a light warm-up walk or jog for 3-5 minutes.",
                "Maintain an upright posture with a slight forward lean.",
                "Land with your foot under your body, not in front.",
                "Keep a comfortable, sustainable pace for your fitness level.",
                "Cool down with a 3-5 minute walk and stretch after."
            ]
        ),
        "Cycling": Info(
            description: "A low-impact cardiovascular exercise on a stationary or road bike that builds leg endurance with minimal joint stress.",
            primaryMuscles: ["Quads", "Hamstrings", "Calves", "Glutes"],
            steps: [
                "Adjust the seat height so your leg has a slight bend at the bottom of the pedal stroke.",
                "Start with a light warm-up at low resistance for 3-5 minutes.",
                "Maintain a steady cadence of 70-90 RPM.",
                "Adjust resistance to match your target intensity.",
                "Cool down with easy pedaling for 3-5 minutes."
            ]
        ),
        "Rowing": Info(
            description: "A full-body cardiovascular exercise on a rowing machine that builds endurance while working the back, legs, and arms.",
            primaryMuscles: ["Back", "Legs", "Arms", "Core"],
            steps: [
                "Sit on the rower with feet secured in the footplates.",
                "Start with legs bent and arms extended gripping the handle.",
                "Drive through your legs first, then lean back slightly, then pull the handle to your lower chest.",
                "Reverse the motion: arms, then lean forward, then bend knees.",
                "Maintain a smooth, fluid rhythm."
            ]
        ),
        "Elliptical": Info(
            description: "A low-impact full-body cardio machine that provides a smooth, joint-friendly workout.",
            primaryMuscles: ["Quads", "Glutes", "Hamstrings", "Arms"],
            steps: [
                "Step onto the machine and grip the moving handles.",
                "Begin pedaling with a smooth, gliding motion.",
                "Maintain an upright posture throughout.",
                "Adjust resistance and incline to vary intensity.",
                "Use both arms and legs for a full-body workout."
            ]
        ),
        "Stair Climber": Info(
            description: "A cardiovascular exercise machine that simulates climbing stairs, building lower body endurance and glute strength.",
            primaryMuscles: ["Quads", "Glutes", "Calves"],
            steps: [
                "Step onto the machine and lightly grip the handrails for balance.",
                "Start at a comfortable step pace.",
                "Drive through each step with your full foot.",
                "Maintain an upright posture without leaning on the rails.",
                "Increase speed gradually as you warm up."
            ]
        ),
        "Jump Rope": Info(
            description: "A high-intensity cardiovascular exercise that improves coordination, footwork, and conditioning.",
            primaryMuscles: ["Calves", "Shoulders", "Core", "Quads"],
            steps: [
                "Hold the rope handles at hip height with elbows close to your sides.",
                "Swing the rope using your wrists, not your arms.",
                "Jump just high enough to clear the rope (1-2 inches).",
                "Land softly on the balls of your feet.",
                "Start with short intervals and build up duration."
            ]
        ),
    ]
}
