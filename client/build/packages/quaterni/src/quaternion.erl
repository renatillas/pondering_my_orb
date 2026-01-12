-module(quaternion).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/quaternion.gleam").
-export([from_axis_angle/2, from_euler/1, to_euler/1, multiply/2, conjugate/1, dot/2, rotate/2, angle/1, axis/1, loosely_equals/3, normalize/1, from_to_rotation/2, inverse/1, spherical_linear_interpolation/3, linear_interpolation/3, look_at/3]).
-export_type([quaternion/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " Pure Gleam quaternion math library for 3D rotations.\n"
    "\n"
    " Quaternions are a mathematical representation of rotations in 3D space that:\n"
    " - Avoid gimbal lock\n"
    " - Provide smooth interpolation (slerp)\n"
    " - Are more compact than rotation matrices\n"
    " - Compose efficiently\n"
    "\n"
    " ## Quick Start\n"
    "\n"
    " ```gleam\n"
    " import q\n"
    " import vec/vec3\n"
    "\n"
    " // Create quaternion from axis-angle\n"
    " let rotation = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)\n"
    "\n"
    " // Or from Euler angles\n"
    " let rotation = q.from_euler(vec3.Vec3(0.0, 1.57, 0.0))\n"
    "\n"
    " // Rotate a vector\n"
    " let rotated = q.rotate(rotation, vec3.Vec3(1.0, 0.0, 0.0))\n"
    "\n"
    " // Interpolate between rotations\n"
    " let halfway = q.slerp(from: rot1, to: rot2, t: 0.5)\n"
    " ```\n"
).

-type quaternion() :: {quaternion, float(), float(), float(), float()}.

-file("src/quaternion.gleam", 61).
?DOC(
    " Create a quaternion from axis-angle representation.\n"
    "\n"
    " ## Parameters\n"
    " - `axis`: The rotation axis\n"
    " - `angle`: The rotation angle in radians\n"
    "\n"
    " ## Example\n"
    " ```gleam\n"
    " // 90 degree rotation around Y axis\n"
    " let rotation = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)\n"
    " ```\n"
).
-spec from_axis_angle(vec@vec3:vec3(float()), float()) -> quaternion().
from_axis_angle(Axis, Angle) ->
    Axis@1 = vec@vec3f:normalize(Axis),
    Half_angle = Angle / 2.0,
    S = gleam_community@maths:sin(Half_angle),
    {quaternion,
        erlang:element(2, Axis@1) * S,
        erlang:element(3, Axis@1) * S,
        erlang:element(4, Axis@1) * S,
        gleam_community@maths:cos(Half_angle)}.

-file("src/quaternion.gleam", 81).
?DOC(
    " Convert Euler angles (radians) to quaternion using XYZ rotation order.\n"
    "\n"
    " ## Example\n"
    " ```gleam\n"
    " // Rotate 90 degrees around Y axis\n"
    " let rotation = q.from_euler(vec3.Vec3(0.0, 1.57, 0.0))\n"
    " ```\n"
).
-spec from_euler(vec@vec3:vec3(float())) -> quaternion().
from_euler(Euler) ->
    C1 = gleam_community@maths:cos(erlang:element(2, Euler) / 2.0),
    C2 = gleam_community@maths:cos(erlang:element(3, Euler) / 2.0),
    C3 = gleam_community@maths:cos(erlang:element(4, Euler) / 2.0),
    S1 = gleam_community@maths:sin(erlang:element(2, Euler) / 2.0),
    S2 = gleam_community@maths:sin(erlang:element(3, Euler) / 2.0),
    S3 = gleam_community@maths:sin(erlang:element(4, Euler) / 2.0),
    {quaternion,
        ((S1 * C2) * C3) + ((C1 * S2) * S3),
        ((C1 * S2) * C3) - ((S1 * C2) * S3),
        ((C1 * C2) * S3) + ((S1 * S2) * C3),
        ((C1 * C2) * C3) - ((S1 * S2) * S3)}.

-file("src/quaternion.gleam", 101).
?DOC(
    " Convert quaternion to Euler angles (radians) using XYZ rotation order.\n"
    "\n"
    " Returns Vec3(roll, pitch, yaw).\n"
).
-spec to_euler(quaternion()) -> vec@vec3:vec3(float()).
to_euler(Quat) ->
    Sinr_cosp = 2.0 * ((erlang:element(5, Quat) * erlang:element(2, Quat)) + (erlang:element(
        3,
        Quat
    )
    * erlang:element(4, Quat))),
    Cosr_cosp = 1.0 - (2.0 * ((erlang:element(2, Quat) * erlang:element(2, Quat))
    + (erlang:element(3, Quat) * erlang:element(3, Quat)))),
    Roll = gleam_community@maths:atan2(Sinr_cosp, Cosr_cosp),
    Sinp = 2.0 * ((erlang:element(5, Quat) * erlang:element(3, Quat)) - (erlang:element(
        4,
        Quat
    )
    * erlang:element(2, Quat))),
    Pitch = case Sinp >= 1.0 of
        true ->
            gleam_community@maths:pi() / 2.0;

        false ->
            case Sinp =< -1.0 of
                true ->
                    +0.0 - (gleam_community@maths:pi() / 2.0);

                false ->
                    _pipe = gleam_community@maths:asin(Sinp),
                    gleam@result:unwrap(_pipe, +0.0)
            end
    end,
    Siny_cosp = 2.0 * ((erlang:element(5, Quat) * erlang:element(4, Quat)) + (erlang:element(
        2,
        Quat
    )
    * erlang:element(3, Quat))),
    Cosy_cosp = 1.0 - (2.0 * ((erlang:element(3, Quat) * erlang:element(3, Quat))
    + (erlang:element(4, Quat) * erlang:element(4, Quat)))),
    Yaw = gleam_community@maths:atan2(Siny_cosp, Cosy_cosp),
    {vec3, Roll, Pitch, Yaw}.

-file("src/quaternion.gleam", 167).
?DOC(
    " Multiply two quaternions (q1 * q2).\n"
    "\n"
    " Represents the combined rotation of applying q1 then q2.\n"
    "\n"
    " ## Example\n"
    " ```gleam\n"
    " let rotate_y = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)\n"
    " let rotate_x = q.from_axis_angle(vec3.Vec3(1.0, 0.0, 0.0), 0.5)\n"
    " let combined = q.multiply(rotate_y, rotate_x)\n"
    " ```\n"
).
-spec multiply(quaternion(), quaternion()) -> quaternion().
multiply(Q1, Q2) ->
    {quaternion,
        (((erlang:element(5, Q1) * erlang:element(2, Q2)) + (erlang:element(
            2,
            Q1
        )
        * erlang:element(5, Q2)))
        + (erlang:element(3, Q1) * erlang:element(4, Q2)))
        - (erlang:element(4, Q1) * erlang:element(3, Q2)),
        (((erlang:element(5, Q1) * erlang:element(3, Q2)) - (erlang:element(
            2,
            Q1
        )
        * erlang:element(4, Q2)))
        + (erlang:element(3, Q1) * erlang:element(5, Q2)))
        + (erlang:element(4, Q1) * erlang:element(2, Q2)),
        (((erlang:element(5, Q1) * erlang:element(4, Q2)) + (erlang:element(
            2,
            Q1
        )
        * erlang:element(3, Q2)))
        - (erlang:element(3, Q1) * erlang:element(2, Q2)))
        + (erlang:element(4, Q1) * erlang:element(5, Q2)),
        (((erlang:element(5, Q1) * erlang:element(5, Q2)) - (erlang:element(
            2,
            Q1
        )
        * erlang:element(2, Q2)))
        - (erlang:element(3, Q1) * erlang:element(3, Q2)))
        - (erlang:element(4, Q1) * erlang:element(4, Q2))}.

-file("src/quaternion.gleam", 203).
?DOC(
    " Compute the conjugate of a quaternion.\n"
    "\n"
    " The conjugate represents the inverse rotation.\n"
).
-spec conjugate(quaternion()) -> quaternion().
conjugate(Quat) ->
    {quaternion,
        +0.0 - erlang:element(2, Quat),
        +0.0 - erlang:element(3, Quat),
        +0.0 - erlang:element(4, Quat),
        erlang:element(5, Quat)}.

-file("src/quaternion.gleam", 228).
?DOC(" Compute the dot product of two quaternions.\n").
-spec dot(quaternion(), quaternion()) -> float().
dot(Q1, Q2) ->
    (((erlang:element(2, Q1) * erlang:element(2, Q2)) + (erlang:element(3, Q1) * erlang:element(
        3,
        Q2
    )))
    + (erlang:element(4, Q1) * erlang:element(4, Q2)))
    + (erlang:element(5, Q1) * erlang:element(5, Q2)).

-file("src/quaternion.gleam", 326).
?DOC(
    " Rotate a vector by a quaternion.\n"
    "\n"
    " ## Example\n"
    " ```gleam\n"
    " let rotation = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)\n"
    " let point = vec3.Vec3(1.0, 0.0, 0.0)\n"
    " let rotated = q.rotate(rotation, point)  // ~Vec3(0.0, 0.0, -1.0)\n"
    " ```\n"
).
-spec rotate(quaternion(), vec@vec3:vec3(float())) -> vec@vec3:vec3(float()).
rotate(Quat, V) ->
    Qx = erlang:element(2, Quat),
    Qy = erlang:element(3, Quat),
    Qz = erlang:element(4, Quat),
    Qw = erlang:element(5, Quat),
    Ix = ((Qw * erlang:element(2, V)) + (Qy * erlang:element(4, V))) - (Qz * erlang:element(
        3,
        V
    )),
    Iy = ((Qw * erlang:element(3, V)) + (Qz * erlang:element(2, V))) - (Qx * erlang:element(
        4,
        V
    )),
    Iz = ((Qw * erlang:element(4, V)) + (Qx * erlang:element(3, V))) - (Qy * erlang:element(
        2,
        V
    )),
    Iw = ((+0.0 - (Qx * erlang:element(2, V))) - (Qy * erlang:element(3, V))) - (Qz
    * erlang:element(4, V)),
    {vec3,
        (((Ix * Qw) + (Iw * (+0.0 - Qx))) + (Iy * (+0.0 - Qz))) - (Iz * (+0.0 - Qy)),
        (((Iy * Qw) + (Iw * (+0.0 - Qy))) + (Iz * (+0.0 - Qx))) - (Ix * (+0.0 - Qz)),
        (((Iz * Qw) + (Iw * (+0.0 - Qz))) + (Ix * (+0.0 - Qy))) - (Iy * (+0.0 - Qx))}.

-file("src/quaternion.gleam", 371).
?DOC(" Get the rotation angle in radians.\n").
-spec angle(quaternion()) -> float().
angle(Quat) ->
    2.0 * begin
        _pipe = gleam_community@maths:acos(
            gleam@float:clamp(erlang:element(5, Quat), -1.0, 1.0)
        ),
        gleam@result:unwrap(_pipe, +0.0)
    end.

-file("src/quaternion.gleam", 378).
?DOC(
    " Get the rotation axis.\n"
    "\n"
    " Returns Error if the quaternion represents no rotation (identity).\n"
).
-spec axis(quaternion()) -> {ok, vec@vec3:vec3(float())} | {error, nil}.
axis(Quat) ->
    S_squared = 1.0 - (erlang:element(5, Quat) * erlang:element(5, Quat)),
    case S_squared < 0.0001 of
        true ->
            {error, nil};

        false ->
            S = case gleam@float:square_root(S_squared) of
                {ok, Val} ->
                    Val;

                {error, _} ->
                    +0.0
            end,
            {ok, {vec3, case S of
                        +0.0 -> +0.0;
                        -0.0 -> -0.0;
                        Gleam@denominator -> erlang:element(2, Quat) / Gleam@denominator
                    end, case S of
                        +0.0 -> +0.0;
                        -0.0 -> -0.0;
                        Gleam@denominator@1 -> erlang:element(3, Quat) / Gleam@denominator@1
                    end, case S of
                        +0.0 -> +0.0;
                        -0.0 -> -0.0;
                        Gleam@denominator@2 -> erlang:element(4, Quat) / Gleam@denominator@2
                    end}}
    end.

-file("src/quaternion.gleam", 543).
?DOC(
    " Check if two quaternions are approximately equal within a tolerance.\n"
    "\n"
    " Useful for floating-point comparisons where exact equality is problematic.\n"
    " Note: Quaternions q and -q represent the same rotation, so this function\n"
    " checks both orientations.\n"
    "\n"
    " ## Parameters\n"
    " - `q1`: First quaternion\n"
    " - `q2`: Second quaternion\n"
    " - `epsilon`: Tolerance for comparison (typically 0.0001 to 0.001)\n"
    "\n"
    " ## Example\n"
    " ```gleam\n"
    " let q1 = from_euler(Vec3(0.0, 1.57, 0.0))\n"
    " let q2 = from_euler(Vec3(0.0, 1.57001, 0.0))\n"
    " loosely_equals(q1, q2, epsilon: 0.001)  // True\n"
    " ```\n"
).
-spec loosely_equals(quaternion(), quaternion(), float()) -> boolean().
loosely_equals(Q1, Q2, Epsilon) ->
    Same_orientation = (((gleam@float:absolute_value(
        erlang:element(2, Q1) - erlang:element(2, Q2)
    )
    < Epsilon)
    andalso (gleam@float:absolute_value(
        erlang:element(3, Q1) - erlang:element(3, Q2)
    )
    < Epsilon))
    andalso (gleam@float:absolute_value(
        erlang:element(4, Q1) - erlang:element(4, Q2)
    )
    < Epsilon))
    andalso (gleam@float:absolute_value(
        erlang:element(5, Q1) - erlang:element(5, Q2)
    )
    < Epsilon),
    Opposite_orientation = (((gleam@float:absolute_value(
        erlang:element(2, Q1) + erlang:element(2, Q2)
    )
    < Epsilon)
    andalso (gleam@float:absolute_value(
        erlang:element(3, Q1) + erlang:element(3, Q2)
    )
    < Epsilon))
    andalso (gleam@float:absolute_value(
        erlang:element(4, Q1) + erlang:element(4, Q2)
    )
    < Epsilon))
    andalso (gleam@float:absolute_value(
        erlang:element(5, Q1) + erlang:element(5, Q2)
    )
    < Epsilon),
    Same_orientation orelse Opposite_orientation.

-file("src/quaternion.gleam", 179).
?DOC(
    " Normalize a quaternion to unit length.\n"
    "\n"
    " All rotation quaternions should be normalized.\n"
).
-spec normalize(quaternion()) -> quaternion().
normalize(Quat) ->
    Mag = gleam@float:square_root(
        (((erlang:element(2, Quat) * erlang:element(2, Quat)) + (erlang:element(
            3,
            Quat
        )
        * erlang:element(3, Quat)))
        + (erlang:element(4, Quat) * erlang:element(4, Quat)))
        + (erlang:element(5, Quat) * erlang:element(5, Quat))
    ),
    case Mag of
        {ok, M} when M > 0.0001 ->
            {quaternion, case M of
                    +0.0 -> +0.0;
                    -0.0 -> -0.0;
                    Gleam@denominator -> erlang:element(2, Quat) / Gleam@denominator
                end, case M of
                    +0.0 -> +0.0;
                    -0.0 -> -0.0;
                    Gleam@denominator@1 -> erlang:element(3, Quat) / Gleam@denominator@1
                end, case M of
                    +0.0 -> +0.0;
                    -0.0 -> -0.0;
                    Gleam@denominator@2 -> erlang:element(4, Quat) / Gleam@denominator@2
                end, case M of
                    +0.0 -> +0.0;
                    -0.0 -> -0.0;
                    Gleam@denominator@3 -> erlang:element(5, Quat) / Gleam@denominator@3
                end};

        _ ->
            {quaternion, +0.0, +0.0, +0.0, 1.0}
    end.

-file("src/quaternion.gleam", 127).
?DOC(" Create a quaternion that rotates from one direction to another.\n").
-spec from_to_rotation(vec@vec3:vec3(float()), vec@vec3:vec3(float())) -> quaternion().
from_to_rotation(From, To) ->
    From@1 = vec@vec3f:normalize(From),
    To@1 = vec@vec3f:normalize(To),
    Dot_val = vec@vec3f:dot(From@1, To@1),
    case Dot_val > 0.999999 of
        true ->
            {quaternion, +0.0, +0.0, +0.0, 1.0};

        false ->
            case Dot_val < -0.999999 of
                true ->
                    Axis = case gleam@float:absolute_value(
                        erlang:element(2, From@1)
                    )
                    < 0.99 of
                        true ->
                            vec@vec3f:normalize(
                                vec@vec3f:cross({vec3, 1.0, +0.0, +0.0}, From@1)
                            );

                        false ->
                            vec@vec3f:normalize(
                                vec@vec3f:cross({vec3, +0.0, 1.0, +0.0}, From@1)
                            )
                    end,
                    from_axis_angle(Axis, gleam_community@maths:pi());

                false ->
                    Axis@1 = vec@vec3f:cross(From@1, To@1),
                    _pipe = {quaternion,
                        erlang:element(2, Axis@1),
                        erlang:element(3, Axis@1),
                        erlang:element(4, Axis@1),
                        1.0 + Dot_val},
                    normalize(_pipe)
            end
    end.

-file("src/quaternion.gleam", 210).
?DOC(
    " Compute the inverse of a quaternion.\n"
    "\n"
    " For unit quaternions (normalized), this is equivalent to the conjugate.\n"
).
-spec inverse(quaternion()) -> quaternion().
inverse(Quat) ->
    Norm_sq = (((erlang:element(2, Quat) * erlang:element(2, Quat)) + (erlang:element(
        3,
        Quat
    )
    * erlang:element(3, Quat)))
    + (erlang:element(4, Quat) * erlang:element(4, Quat)))
    + (erlang:element(5, Quat) * erlang:element(5, Quat)),
    case Norm_sq > 0.0001 of
        true ->
            Conj = conjugate(Quat),
            {quaternion, case Norm_sq of
                    +0.0 -> +0.0;
                    -0.0 -> -0.0;
                    Gleam@denominator -> erlang:element(2, Conj) / Gleam@denominator
                end, case Norm_sq of
                    +0.0 -> +0.0;
                    -0.0 -> -0.0;
                    Gleam@denominator@1 -> erlang:element(3, Conj) / Gleam@denominator@1
                end, case Norm_sq of
                    +0.0 -> +0.0;
                    -0.0 -> -0.0;
                    Gleam@denominator@2 -> erlang:element(4, Conj) / Gleam@denominator@2
                end, case Norm_sq of
                    +0.0 -> +0.0;
                    -0.0 -> -0.0;
                    Gleam@denominator@3 -> erlang:element(5, Conj) / Gleam@denominator@3
                end};

        false ->
            {quaternion, +0.0, +0.0, +0.0, 1.0}
    end.

-file("src/quaternion.gleam", 249).
?DOC(
    " Spherical linear interpolation (slerp) between two quaternions.\n"
    "\n"
    " Provides smooth rotation interpolation without gimbal lock issues.\n"
    "\n"
    " ## Parameters\n"
    " - `from`: Starting quaternion\n"
    " - `to`: Target quaternion\n"
    " - `t`: Interpolation factor (0.0 = from, 1.0 = to)\n"
    "\n"
    " ## Example\n"
    " ```gleam\n"
    " let start = q.from_euler(vec3.Vec3(0.0, 0.0, 0.0))\n"
    " let end = q.from_euler(vec3.Vec3(0.0, 1.57, 0.0))\n"
    " let halfway = q.slerp(from: start, to: end, t: 0.5)\n"
    " ```\n"
).
-spec spherical_linear_interpolation(quaternion(), quaternion(), float()) -> quaternion().
spherical_linear_interpolation(From, To, T) ->
    Dot_prod = dot(From, To),
    {To@1, Dot_prod@1} = case Dot_prod < +0.0 of
        true ->
            {{quaternion,
                    +0.0 - erlang:element(2, To),
                    +0.0 - erlang:element(3, To),
                    +0.0 - erlang:element(4, To),
                    +0.0 - erlang:element(5, To)},
                +0.0 - Dot_prod};

        false ->
            {To, Dot_prod}
    end,
    case Dot_prod@1 > 0.9995 of
        true ->
            _pipe = {quaternion,
                erlang:element(2, From) + ((erlang:element(2, To@1) - erlang:element(
                    2,
                    From
                ))
                * T),
                erlang:element(3, From) + ((erlang:element(3, To@1) - erlang:element(
                    3,
                    From
                ))
                * T),
                erlang:element(4, From) + ((erlang:element(4, To@1) - erlang:element(
                    4,
                    From
                ))
                * T),
                erlang:element(5, From) + ((erlang:element(5, To@1) - erlang:element(
                    5,
                    From
                ))
                * T)},
            normalize(_pipe);

        false ->
            Dot_clamped = gleam@float:clamp(Dot_prod@1, -1.0, 1.0),
            Theta_0 = begin
                _pipe@1 = gleam_community@maths:acos(Dot_clamped),
                gleam@result:unwrap(_pipe@1, +0.0)
            end,
            Theta = Theta_0 * T,
            Sin_theta = gleam_community@maths:sin(Theta),
            Sin_theta_0 = gleam_community@maths:sin(Theta_0),
            S1 = gleam_community@maths:cos(Theta) - (case Sin_theta_0 of
                +0.0 -> +0.0;
                -0.0 -> -0.0;
                Gleam@denominator -> Dot_clamped * Sin_theta / Gleam@denominator
            end),
            S2 = case Sin_theta_0 of
                +0.0 -> +0.0;
                -0.0 -> -0.0;
                Gleam@denominator@1 -> Sin_theta / Gleam@denominator@1
            end,
            {quaternion,
                (erlang:element(2, From) * S1) + (erlang:element(2, To@1) * S2),
                (erlang:element(3, From) * S1) + (erlang:element(3, To@1) * S2),
                (erlang:element(4, From) * S1) + (erlang:element(4, To@1) * S2),
                (erlang:element(5, From) * S1) + (erlang:element(5, To@1) * S2)}
    end.

-file("src/quaternion.gleam", 302).
?DOC(
    " Linear interpolation between two quaternions.\n"
    "\n"
    " Faster than slerp but doesn't maintain constant angular velocity.\n"
    " Result should be normalized.\n"
).
-spec linear_interpolation(quaternion(), quaternion(), float()) -> quaternion().
linear_interpolation(From, To, T) ->
    _pipe = {quaternion,
        erlang:element(2, From) + ((erlang:element(2, To) - erlang:element(
            2,
            From
        ))
        * T),
        erlang:element(3, From) + ((erlang:element(3, To) - erlang:element(
            3,
            From
        ))
        * T),
        erlang:element(4, From) + ((erlang:element(4, To) - erlang:element(
            4,
            From
        ))
        * T),
        erlang:element(5, From) + ((erlang:element(5, To) - erlang:element(
            5,
            From
        ))
        * T)},
    normalize(_pipe).

-file("src/quaternion.gleam", 448).
?DOC(" Convert a 3x3 rotation matrix to quaternion using Shepperd's method.\n").
-spec matrix_to_quaternion(
    float(),
    float(),
    float(),
    float(),
    float(),
    float(),
    float(),
    float(),
    float()
) -> quaternion().
matrix_to_quaternion(M00, M01, M02, M10, M11, M12, M20, M21, M22) ->
    Trace = (M00 + M11) + M22,
    case Trace > +0.0 of
        true ->
            S = begin
                _pipe = gleam@float:square_root(Trace + 1.0),
                gleam@result:unwrap(_pipe, 1.0)
            end,
            W = S / 2.0,
            S@1 = case S of
                +0.0 -> +0.0;
                -0.0 -> -0.0;
                Gleam@denominator -> 0.5 / Gleam@denominator
            end,
            _pipe@1 = {quaternion,
                (M21 - M12) * S@1,
                (M02 - M20) * S@1,
                (M10 - M01) * S@1,
                W},
            normalize(_pipe@1);

        false ->
            case (M00 > M11) andalso (M00 > M22) of
                true ->
                    S@2 = begin
                        _pipe@2 = gleam@float:square_root(
                            ((1.0 + M00) - M11) - M22
                        ),
                        gleam@result:unwrap(_pipe@2, 1.0)
                    end,
                    X = S@2 / 2.0,
                    S@3 = case S@2 of
                        +0.0 -> +0.0;
                        -0.0 -> -0.0;
                        Gleam@denominator@1 -> 0.5 / Gleam@denominator@1
                    end,
                    _pipe@3 = {quaternion,
                        X,
                        (M01 + M10) * S@3,
                        (M02 + M20) * S@3,
                        (M21 - M12) * S@3},
                    normalize(_pipe@3);

                false ->
                    case M11 > M22 of
                        true ->
                            S@4 = begin
                                _pipe@4 = gleam@float:square_root(
                                    ((1.0 + M11) - M00) - M22
                                ),
                                gleam@result:unwrap(_pipe@4, 1.0)
                            end,
                            Y = S@4 / 2.0,
                            S@5 = case S@4 of
                                +0.0 -> +0.0;
                                -0.0 -> -0.0;
                                Gleam@denominator@2 -> 0.5 / Gleam@denominator@2
                            end,
                            _pipe@5 = {quaternion,
                                (M01 + M10) * S@5,
                                Y,
                                (M12 + M21) * S@5,
                                (M02 - M20) * S@5},
                            normalize(_pipe@5);

                        false ->
                            S@6 = begin
                                _pipe@6 = gleam@float:square_root(
                                    ((1.0 + M22) - M00) - M11
                                ),
                                gleam@result:unwrap(_pipe@6, 1.0)
                            end,
                            Z = S@6 / 2.0,
                            S@7 = case S@6 of
                                +0.0 -> +0.0;
                                -0.0 -> -0.0;
                                Gleam@denominator@3 -> 0.5 / Gleam@denominator@3
                            end,
                            _pipe@7 = {quaternion,
                                (M02 + M20) * S@7,
                                (M12 + M21) * S@7,
                                Z,
                                (M10 - M01) * S@7},
                            normalize(_pipe@7)
                    end
            end
    end.

-file("src/quaternion.gleam", 424).
?DOC(
    " Internal helper: compute quaternion for looking at a direction with given up vector.\n"
    " Assumes the default forward is -Z.\n"
).
-spec look_at_direction(vec@vec3:vec3(float()), vec@vec3:vec3(float())) -> quaternion().
look_at_direction(Direction, Up) ->
    Dir_norm = vec@vec3f:normalize(Direction),
    Up_norm = vec@vec3f:normalize(Up),
    Right = vec@vec3f:normalize(vec@vec3f:cross(Dir_norm, Up_norm)),
    New_up = vec@vec3f:cross(Right, Dir_norm),
    M00 = erlang:element(2, Right),
    M10 = erlang:element(3, Right),
    M20 = erlang:element(4, Right),
    M01 = erlang:element(2, New_up),
    M11 = erlang:element(3, New_up),
    M21 = erlang:element(4, New_up),
    M02 = +0.0 - erlang:element(2, Dir_norm),
    M12 = +0.0 - erlang:element(3, Dir_norm),
    M22 = +0.0 - erlang:element(4, Dir_norm),
    matrix_to_quaternion(M00, M01, M02, M10, M11, M12, M20, M21, M22).

-file("src/quaternion.gleam", 410).
?DOC(
    " Create a quaternion that looks from one direction toward a target direction.\n"
    "\n"
    " Creates a rotation that orients the `forward` direction to point toward the `target` direction,\n"
    " with the given `up` vector for orientation. Useful for cameras and billboards.\n"
    "\n"
    " ## Parameters\n"
    " - `forward`: The current forward direction (usually Vec3(0.0, 0.0, -1.0) for cameras)\n"
    " - `target`: The direction to look toward  \n"
    " - `up`: The up vector for orientation (usually Vec3(0.0, 1.0, 0.0))\n"
    "\n"
    " ## Example\n"
    " ```gleam\n"
    " // Make camera look at target from position\n"
    " let camera_pos = Vec3(10.0, 10.0, 10.0)\n"
    " let target_pos = Vec3(0.0, 0.0, 0.0)\n"
    " let direction = vec3f.normalize(vec3f.subtract(target_pos, camera_pos))\n"
    " let quat = look_at(Vec3(0.0, 0.0, -1.0), direction, Vec3(0.0, 1.0, 0.0))\n"
    " ```\n"
).
-spec look_at(
    vec@vec3:vec3(float()),
    vec@vec3:vec3(float()),
    vec@vec3:vec3(float())
) -> quaternion().
look_at(Forward, Target, Up) ->
    Q_target = look_at_direction(Target, Up),
    Q_forward = look_at_direction(Forward, Up),
    multiply(Q_target, inverse(Q_forward)).
