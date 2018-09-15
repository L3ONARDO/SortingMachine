/**
 * Describes the software functionality in a pseudocode-like way.
 * In the assembler program, unlike in the following code:
 * 1) PWM is used on specific outputs instead of dispenser.on = true, belt.left = true and belt.right = true.
 *    Setting those values to false just implies setting a specific output to 0.
 * 2) Lamps for several detectors are connected to one output of the PP2.
 * 3) On PP2 counter with timer interrupts will be used for SWS and SBS states.
 * @author Aleksandr Popov, Group 17
 */
public class Controller
{
    /**
     * JAVA simulation of parts of the system.
     */
    private Button startStopBtn;
    private Button abortBtn;
    private BWDetector bwDetector;
    private ConveyorBelt belt;
    private Detector[] sideDetectors;
    private Detector presenceDetector;
    private Dispenser dispenser;

    /**
     * Variables used to maintain states.
     */
    private boolean leftTrayDetected;
    private boolean rightTrayDetected;
    private boolean stopped;
    private long startTime;
    private boolean timeSet;

    /**
     * Possible states of the system.
     */
    private enum State
    {
        INIT, INIT1, INIT2, READY, SP, SD, SW1, SW2, SW3, SB1, SB2, SB3, SWS, SBS
    }

    private State state;

    /**
     * Initializes parts of the system in JAVA way.
     * Won't be used in assembly.
     */
    public Controller()
    {
        startStopBtn = new Button();
        abortBtn = new Button();
        bwDetector = new BWDetector();
        belt = new ConveyorBelt();
        sideDetectors = new Detector[2];
        sideDetectors[0] = new Detector();
        sideDetectors[1] = new Detector();
        presenceDetector = new Detector();
        dispenser = new Dispenser();
        leftTrayDetected = false;
        rightTrayDetected = false;
        timeSet = false;
    }

    /**
     * Describes the functionality of the program.
     * Implemented as a state machine.
     */
    public void work()
    {
        while (true)
        {
            if (abortBtn.pressed)
                abort();
            if (startStopBtn.pressed)
            {
                if (state != INIT && state != INIT1 &&
                    state != INIT2 && state != READY)
                {
                    stopped = true;
                }
            }
            switch (state)
            {
                case INIT:
                    checkInit();
                    break;
                case INIT1:
                    checkInit1();
                    break;
                case INIT2:
                    checkInit2();
                    break;
                case READY:
                    checkReady();
                    break;
                case SP:
                    checkSP();
                    break;
                case SD:
                    checkSD();
                    break;
                case SW1:
                    checkSW1();
                    break;
                case SW2:
                    checkSW2();
                    break;
                case SW3:
                    checkSW3();
                    break;
                case SB1:
                    checkSB1();
                    break;
                case SB2:
                    checkSB2();
                    break;
                case SB3:
                    checkSB3();
                    break;
                case SWS:
                    checkSWS();
                    break;
                case SBS:
                    checkSBS();
                    break;
                default:
                    // Something went wrong
                    abort();
            }
        }
    }

    /**
     * Checks to be performed in the initial state.
     */
    private void checkInit()
    {
        if (startStopBtn.pressed)
        {
            if (!dispenser.pressed)
                state = State.INIT1;
            else
                state = State.INIT2;
        }
    }

    /**
     * First phase of initialization.
     */
    private void checkInit1()
    {
        dispenser.on = true;
        pwm(0);
        if (dispenser.pressed)
            state = State.INIT2;
    }

    /**
     * Second phase of the initialization.
     */
    private void checkInit2()
    {
        dispenser.on = true;
        pwm(0);
        if (!dispenser.pressed)
        {
            state = State.READY;
            dispenser.on = false;
            presenceDetector.lightOn = true;
            sideDetectors[0].lightOn = true;
            sideDetectors[1].lightOn = true;
            bwDetector.lightOn = true;
        }
    }

    /**
     * Machine is ready to start sorting.
     */
    private void checkReady()
    {
        if (startStopBtn.pressed && presenceDetector.presentDisc)
        {
            state = State.SP;
            stopped = false;
        }
    }

    /**
     * Pushing the disc to the BW detector for the first time.
     */
    private void checkSP()
    {
        dispenser.on = true;
        pwm(0);
        if (dispenser.pressed)
        {
            state = State.SD;
            dispenser.on = false;
        }
    }

    /**
     * Check the disc color.
     */
    private void checkSD()
    {
        if (bwDetector.value < 70) // white
            state = State.SW1;
        else if (bwDetector.value < 190) // black
            state = State.SB1;
        else
            abort();
    }

    /**
     * Start delivering the white disc.
     */
    private void checkSW1()
    {
        belt.left = true;
        pwm(7);
        dispenser.on = true;
        pwm(0);
        if (sideDetectors[0].presentDisc)
            leftTrayDetected = true;
        if (!dispenser.pressed && (stopped || !presenceDetector.presentDisc))
        {
            state = State.SWS;
            dispenser.on = false;
        }
        if (!dispenser.pressed)
            state = State.SW2;
    }

    /**
     * Continue delivering the white disc.
     */
    private void checkSW2()
    {
        belt.left = true;
        pwm(7);
        dispenser.on = true;
        pwm(0);
        if (sideDetectors[0].presentDisc)
            leftTrayDetected = true;
        if (dispenser.pressed)
        {
            state = State.SW3;
            belt.left = false;
            dispenser.on = false;
        }
    }

    /**
     * Check if it has been delivered and check the next disc color.
     */
    private void checkSW3()
    {
        if (leftTrayDetected)
            state = State.SD;
        else
            abort();
    }

    /**
     * Start delivering the black disc.
     */
    private void checkSB1()
    {
        belt.right = true;
        pwm(6);
        dispenser.on = true;
        pwm(0);
        if (sideDetectors[1].presentDisc)
            rightTrayDetected = true;
        if (!dispenser.pressed && (stopped || !presenceDetector.presentDisc))
        {
            state = State.SWS;
            dispenser.on = false;
        }
        if (!dispenser.pressed)
            state = State.SB2;
    }

    /**
     * Continue delivering the black disc.
     */
    private void checkSB2()
    {
        belt.right = true;
        pwm(6);
        dispenser.on = true;
        pwm(0);
        if (sideDetectors[1].presentDisc)
            rightTrayDetected = true;
        if (dispenser.pressed)
        {
            state = State.SB3;
            belt.right = false;
            dispenser.on = false;
        }
    }

    /**
     * Check if it has been delivered and check the next disc color.
     */
    private void checkSB3()
    {
        if (rightTrayDetected)
            state = State.SD;
        else
            abort();
    }

    /**
     * Deliver the last white disc and stop.
     */
    private void checkSWS()
    {
        belt.left = true;
        pwm(7);
        if (!timeSet)
            startTime = System.currentTimeMillis();
        if (sideDetectors[0].presentDisc)
            leftTrayDetected = true;
        if (leftTrayDetected)
        {
            state = State.READY;
            belt.left = false;
            timeSet = false;
        }
        if (System.currentTimeMillis() - startTime > 1500)
        {
            timeSet = false;
            abort();
        }
    }

    /**
     * Deliver the last black disc and stop.
     */
    private void checkSBS()
    {
        belt.right = true;
        pwm(6);
        if (!timeSet)
            startTime = System.currentTimeMillis();
        if (sideDetectors[1].presentDisc)
            rightTrayDetected = true;
        if (rightTrayDetected)
        {
            state = State.READY;
            belt.right = false;
            timeSet = false;
        }
        if (System.currentTimeMillis() - startTime > 1500)
        {
            timeSet = false;
            abort();
        }
    }

    /**
     * Actions to be performed in case of abort.
     */
    private void abort()
    {
        state = State.INIT;
        belt.left = false;
        belt.right = false;
        dispenser.on = false;
        sideDetectors[0].lightOn = false;
        sideDetectors[1].lightOn = false;
        presenceDetector.lightOn = false;
        bwDetector.lightOn = false;
        timeSet = false;
        stopped = false;
        leftTrayDetected = false;
        rightTrayDetected = false;
    }

    /**
     * Models the pulse-width modulation.
     */
    private void pwm(int output)
    {
        static int cnt = 0;
        if (cnt < 8)
            PP2OUTPUT[output] = true;
        else
            PP2OUTPUT[output] = false;
        cnt++;
        cnt %= 10;
    }
}
